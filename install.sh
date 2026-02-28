#!/bin/bash

# =============================================================================
#  ███████╗      ███████╗██╗  ██╗██╗███████╗████████╗
#  ╚══███╔╝      ██╔════╝██║  ██║██║██╔════╝╚══██╔══╝
#    ███╔╝ █████╗███████╗███████║██║█████╗     ██║   
#   ███╔╝  ╚════╝╚════██║██╔══██║██║██╔══╝     ██║   
#  ███████╗      ███████╗██║  ██║██║██║        ██║   
#  ╚══════╝      ╚══════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   
# =============================================================================
#  Z-SHIFT: High-Performance Zsh + Starship + Zinit installation script
# =============================================================================

# Removed bare 'set -e' in favour of explicit checks on critical commands
# 'set -e' interacts poorly with subshells and conditional logic.
set -uo pipefail

# --- COLORS ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# --- ROOT CHECK ---
if [ "$EUID" -eq 0 ] && [ "${CI_ENV:-}" != "true" ]; then
    echo -e "${RED}Please do not run this script as root or with sudo.${NC}"
    echo -e "${YELLOW}The script will prompt for your sudo password when needed.${NC}"
    exit 1
fi

# --- GLOBAL VARIABLES & CLEANUP TRAP ---
TEMP_DIRS=()

cleanup() {
    for d in "${TEMP_DIRS[@]}"; do
        [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"
    done
}
trap cleanup EXIT INT TERM

# --- CONFIGURATION ---
ZSHRC_URL="${ZSHIFT_CUSTOM_URL:-https://raw.githubusercontent.com/0xdilshan/Z-SHIFT/main/.zshrc}"

echo -e "${CYAN}>>> Initiating Z-Shift Environment Deployment...${NC}"

# =============================================================================
# 0. OS & PACKAGE MANAGER DETECTION
# =============================================================================
OS_TYPE="unknown"
DISTRO="unknown"
DISTRO_LIKE="unknown"

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
    DISTRO="macos"
elif [ -f /etc/os-release ]; then
    OS_TYPE="linux"
    # shellcheck disable=SC1091
    . /etc/os-release
    DISTRO="${ID:-unknown}"
    DISTRO_LIKE="${ID_LIKE:-unknown}"  # Catches derivatives (e.g. ID_LIKE="debian")
fi

echo -e "${BLUE}Detected OS: ${OS_TYPE} (${DISTRO})${NC}"

# Resolve distro family from ID or ID_LIKE
_resolve_distro_family() {
    local id="$1"
    local id_like="$2"

    case "$id" in
        ubuntu|debian|pop|kali|linuxmint|raspbian|elementary|zorin)
            echo "debian" ;;
        arch|manjaro|endeavouros|garuda|artix)
            echo "arch" ;;
        fedora|rhel|centos|rocky|almalinux|nobara)
            echo "fedora" ;;
        opensuse*|suse*)
            echo "suse" ;;
        *)
            # Fall back to ID_LIKE for unrecognised derivatives
            case "$id_like" in
                *debian*|*ubuntu*) echo "debian" ;;
                *arch*)            echo "arch"   ;;
                *fedora*|*rhel*)   echo "fedora" ;;
                *suse*)            echo "suse"   ;;
                *)                 echo "unknown" ;;
            esac
            ;;
    esac
}

DISTRO_FAMILY="$(_resolve_distro_family "$DISTRO" "$DISTRO_LIKE")"

install_pkg() {
    local pkgs=("$@")
    echo -e "${YELLOW}Installing: ${pkgs[*]}...${NC}"

    case "$DISTRO_FAMILY" in
        debian)
            export DEBIAN_FRONTEND=noninteractive
            sudo apt-get update -qq -y > /dev/null
            sudo apt-get install -qq -y "${pkgs[@]}" > /dev/null
            ;;
        arch)
            sudo pacman -Sy --quiet --noconfirm --needed "${pkgs[@]}" > /dev/null
            ;;
        fedora)
            sudo dnf install -q -y "${pkgs[@]}" > /dev/null
            ;;
        suse)
            sudo zypper install -q -y "${pkgs[@]}" > /dev/null
            ;;
        macos)
            brew install -q "${pkgs[@]}" > /dev/null
            ;;
        *)
            echo -e "${RED}Unsupported distribution: ${DISTRO} (family: ${DISTRO_FAMILY})${NC}"
            echo -e "${RED}Please install the following packages manually: ${pkgs[*]}${NC}"
            exit 1
            ;;
    esac
}

# =============================================================================
# 1. PRE-REQUISITES (Homebrew for macOS)
# =============================================================================
if [[ "$OS_TYPE" == "macos" ]]; then
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Homebrew not found. Installing Homebrew (this may take a while)...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null || {
            echo -e "${RED}Homebrew installation failed.${NC}"; exit 1
        }
        # Support both Apple Silicon (/opt/homebrew) and Intel (/usr/local) paths
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
fi

# =============================================================================
# 2. SYSTEM DEPENDENCIES
# =============================================================================
echo -e "${YELLOW}Installing base dependencies...${NC}"

COMMON_DEPS=(git curl wget unzip zsh gnupg)

if [[ "$OS_TYPE" == "macos" ]]; then
    install_pkg "${COMMON_DEPS[@]}"
else
    install_pkg "${COMMON_DEPS[@]}"
fi

# =============================================================================
# 2.1 CLIPBOARD UTILITY
# =============================================================================
# macOS ships with pbcopy/pbpaste natively — no installation required.
# Linux needs xclip (X11) or wl-clipboard (Wayland) for clipboard access.
if [[ "$OS_TYPE" == "linux" ]]; then
    echo -e "${YELLOW}Installing clipboard utility...${NC}"

    # Detect display server: Wayland takes priority, fall back to X11
    if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        echo -e "${BLUE}Wayland detected — installing wl-clipboard${NC}"
        case "$DISTRO_FAMILY" in
            debian) install_pkg wl-clipboard ;;
            arch)   install_pkg wl-clipboard ;;
            fedora) install_pkg wl-clipboard ;;
            suse)   install_pkg wl-clipboard ;;
        esac
    elif [[ -n "${DISPLAY:-}" ]]; then
        echo -e "${BLUE}X11 detected — installing xclip${NC}"
        case "$DISTRO_FAMILY" in
            debian) install_pkg xclip ;;
            arch)   install_pkg xclip ;;
            fedora) install_pkg xclip ;;
            suse)   install_pkg xclip ;;
        esac
    else
        # Headless / TTY-only: install both so the env is ready for either
        echo -e "${YELLOW}No display server detected (headless/TTY) — installing xclip + wl-clipboard as fallback${NC}"
        case "$DISTRO_FAMILY" in
            debian) install_pkg xclip wl-clipboard ;;
            arch)   install_pkg xclip wl-clipboard ;;
            fedora) install_pkg xclip wl-clipboard ;;
            suse)   install_pkg xclip wl-clipboard ;;
        esac
    fi

    # Verify at least one clipboard tool landed
    if ! command -v xclip &>/dev/null && ! command -v wl-copy &>/dev/null; then
        echo -e "${RED}Warning: no clipboard utility found after installation.${NC}"
        echo -e "${RED}You may need to install xclip or wl-clipboard manually.${NC}"
    else
        echo -e "${GREEN}Clipboard utility installed successfully.${NC}"
    fi
fi

# =============================================================================
# 3. INSTALL STANDALONE TOOLS (Eza)
# =============================================================================
echo -e "${YELLOW}Installing Eza (ls replacement)...${NC}"

if command -v eza &> /dev/null; then
    echo -e "${GREEN}:: Eza is already installed. Skipping.${NC}"
else
    case "$DISTRO" in
        ubuntu|debian|pop|kali|linuxmint)
            export DEBIAN_FRONTEND=noninteractive
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
                | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg > /dev/null 2>&1 || true

            echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
                | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null

            sudo chmod 644 /etc/apt/keyrings/gierens.gpg \
                /etc/apt/sources.list.d/gierens.list

            sudo apt-get update -qq -y > /dev/null && sudo apt-get install -qq -y eza > /dev/null
            ;;

        fedora)
            FEDORA_VERSION=$(rpm -E %fedora)

            if [ "$FEDORA_VERSION" -ge 42 ]; then
                echo -e "${YELLOW}:: Fedora $FEDORA_VERSION detected. Downloading binary...${NC}"

                ARCH=$(uname -m)
                case "$ARCH" in
                    x86_64)  BINARY_ARCH="x86_64-unknown-linux-gnu" ;;
                    aarch64) BINARY_ARCH="aarch64-unknown-linux-gnu" ;;
                    armv7l)  BINARY_ARCH="arm-unknown-linux-gnueabihf" ;;
                    *)
                        echo -e "${RED}Unsupported arch: $ARCH${NC}"
                        exit 1
                        ;;
                esac

                FILENAME="eza_${BINARY_ARCH}.tar.gz"
                URL="https://github.com/eza-community/eza/releases/latest/download/${FILENAME}"

                EZA_TMP=$(mktemp -d)
                TEMP_DIRS+=("$EZA_TMP")

                curl -sSL "$URL" | tar -xz -C "$EZA_TMP" || {
                    echo -e "${RED}Error: Failed to download/extract eza binary.${NC}"; exit 1
                }

                if [ -f "$EZA_TMP/eza" ]; then
                    sudo mv "$EZA_TMP/eza" /usr/local/bin/eza
                    sudo chmod +x /usr/local/bin/eza
                    echo -e "${GREEN}:: eza installed successfully to /usr/local/bin/eza${NC}"
                else
                    echo -e "${RED}Error: Binary 'eza' not found in archive.${NC}"
                    exit 1
                fi
            else
                sudo dnf install -q -y eza > /dev/null
            fi
            ;;

        *)
            install_pkg eza
            ;;
    esac
fi

# =============================================================================
# 4. CONFIGURATION (Themes & Starship)
# =============================================================================
echo -e "${YELLOW}Setting up Configuration...${NC}"

rm -rf "$HOME/.config/eza-themes"
git clone --quiet https://github.com/eza-community/eza-themes.git "$HOME/.config/eza-themes" > /dev/null 2>&1
mkdir -p "$HOME/.config/eza"
mkdir -p "$HOME/.config"

if command -v starship &> /dev/null; then
    echo -e "${GREEN}:: Starship is already installed. Skipping.${NC}"
else
    if [[ "$OS_TYPE" == "macos" ]]; then
        install_pkg starship
    else
        curl -sS https://starship.rs/install.sh | sh -s -- -y > /dev/null || {
            echo -e "${RED}Starship installation failed.${NC}"; exit 1
        }
    fi
fi

STARSHIP_THEMES=(
    "gruvbox-rainbow" "nerd-font-symbols" "no-nerd-font"
    "bracketed-segments" "plain-text-symbols" "no-runtime-versions"
    "no-empty-icons" "pure-preset" "pastel-powerline"
    "tokyo-night" "jetpack" "catppuccin-powerline"
)

EZA_THEMES=(
    "gruvbox-dark.yml" "black.yml" "catppuccin-frappe.yml"
    "catppuccin-latte.yml" "catppuccin-macchiato.yml" "catppuccin-mocha.yml"
    "default.yml" "dracula.yml" "frosty.yml" "gruvbox-light.yml"
    "one_dark.yml" "rose-pine-dawn.yml" "rose-pine-moon.yml"
    "rose-pine.yml" "solarized-dark.yml" "tokyonight.yml" "white.yml"
)

SELECTED_STARSHIP="gruvbox-rainbow"
SELECTED_EZA="gruvbox-dark.yml"

if [ "${CI_ENV:-}" != "true" ]; then
    if [ ! -t 0 ]; then
        exec < /dev/tty
    fi

    echo -e "\n${CYAN}::: THEME SELECTION :::${NC}"
    echo "1) Default (Starship: Gruvbox-Rainbow | Eza: Gruvbox-Dark)"
    echo "2) Custom Selection"
    echo -ne "${YELLOW}Select option [1-2] (default: 1): ${NC}"
    read -r THEME_OPT

    if [[ "$THEME_OPT" == "2" ]]; then
        echo -e "\n${BLUE}:: Select Starship Prompt Theme ::${NC}"
        PS3="Enter number (1-${#STARSHIP_THEMES[@]}): "
        select s_theme in "${STARSHIP_THEMES[@]}"; do
            if [[ -n "$s_theme" ]]; then
                SELECTED_STARSHIP="$s_theme"
                break
            else
                echo -e "${RED}Invalid selection. Try again.${NC}"
            fi
        done

        echo -e "\n${BLUE}:: Select Eza (ls) Theme ::${NC}"
        PS3="Enter number (1-${#EZA_THEMES[@]}): "
        select e_theme in "${EZA_THEMES[@]}"; do
            if [[ -n "$e_theme" ]]; then
                SELECTED_EZA="$e_theme"
                break
            else
                echo -e "${RED}Invalid selection. Try again.${NC}"
            fi
        done
    else
        echo -e "${GREEN}>> Using Default Themes.${NC}"
    fi
fi

echo -e "${YELLOW}Applying Starship Preset: ${SELECTED_STARSHIP}...${NC}"
starship preset "$SELECTED_STARSHIP" -o "$HOME/.config/starship.toml" > /dev/null 2>&1 || \
    echo -e "${RED}Warning: Failed to load preset '$SELECTED_STARSHIP'. Check starship version.${NC}"

echo -e "${YELLOW}Applying Eza Theme: ${SELECTED_EZA}...${NC}"
ln -sf "$HOME/.config/eza-themes/themes/${SELECTED_EZA}" "$HOME/.config/eza/theme.yml"

echo -e "${YELLOW}Optimizing Zsh startup...${NC}"
if ! grep -q "skip_global_compinit=1" "$HOME/.zshenv" 2>/dev/null; then
    echo 'skip_global_compinit=1' >> "$HOME/.zshenv"
fi

# =============================================================================
# 5. FONTS (FiraCode Nerd Font)
# =============================================================================
if [ "${CI_ENV:-}" = "true" ]; then
    echo -e "${YELLOW}>> CI Environment detected. Skipping Font Installation.${NC}"
else
    if [ ! -t 0 ]; then
        exec < /dev/tty
    fi

    if [[ "$OS_TYPE" == "macos" ]]; then
        FONT_DIR="$HOME/Library/Fonts"
    else
        FONT_DIR="$HOME/.local/share/fonts"
    fi

    if ls "$FONT_DIR"/FiraCode* >/dev/null 2>&1; then
        echo -e "${GREEN}:: FiraCode Nerd Font already installed. Skipping.${NC}"
    else
        echo -e "\n${CYAN}::: FONT INSTALLATION :::${NC}"
        echo -ne "${YELLOW}Install FiraCode Nerd Font? [Y/n] (default: Y): ${NC}"
        read -r FONT_OPT

        if [[ "$FONT_OPT" =~ ^[Nn]$ ]]; then
            echo -e "${BLUE}>> Skipping Font Installation.${NC}"
        else
            echo -e "${YELLOW}Installing FiraCode Nerd Font...${NC}"

            mkdir -p "$FONT_DIR"

            FONT_VER=$(curl -fsSL "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" \
                | grep '"tag_name"' | cut -d'"' -f4)
            if [ -z "$FONT_VER" ]; then
                echo -e "${YELLOW}Warning: Could not determine latest font version. Falling back to v3.4.0.${NC}"
                FONT_VER="v3.4.0"
            fi

            FONT_TMP=$(mktemp -d)
            TEMP_DIRS+=("$FONT_TMP")

            wget -q -O "$FONT_TMP/FiraCode.zip" \
                "https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VER}/FiraCode.zip" || {
                echo -e "${RED}Font download failed. Skipping.${NC}"
            }

            if [ -f "$FONT_TMP/FiraCode.zip" ]; then
                unzip -q "$FONT_TMP/FiraCode.zip" -d "$FONT_TMP"
                find "$FONT_TMP" -name "*.ttf" -exec mv -f {} "$FONT_DIR/" \; 2>/dev/null || true

                if [[ "$OS_TYPE" == "linux" ]] && command -v fc-cache &> /dev/null; then
                    fc-cache -f -q "$FONT_DIR" > /dev/null 2>&1
                fi
                echo -e "${GREEN}✔ Font installation complete (${FONT_VER}).${NC}"
            fi
        fi
    fi
fi

# =============================================================================
# 6. DOWNLOAD .ZSHRC
# =============================================================================
echo -e "${YELLOW}Downloading .zshrc from GitHub...${NC}"
[ -f "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.bak"

if curl -fsSL -o "$HOME/.zshrc" "$ZSHRC_URL"; then
    echo -e "${GREEN}Downloaded .zshrc successfully.${NC}"
else
    echo -e "${RED}Failed to download .zshrc!${NC}"
    [ -f "$HOME/.zshrc.bak" ] && mv "$HOME/.zshrc.bak" "$HOME/.zshrc"
    exit 1
fi

# =============================================================================
# 7. FINALIZE
# =============================================================================
ZSH_PATH=$(command -v zsh || true)

if [ -z "$ZSH_PATH" ]; then
    echo -e "${RED}Error: Zsh binary not found. Please verify the installation.${NC}"
    exit 1
fi

if [ "${CI_ENV:-}" = "true" ]; then
    echo -e "\n${GREEN}✔ CI Environment detected. Installation Verified!${NC}"
    exit 0
fi

if ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
fi

if [ "$SHELL" != "$ZSH_PATH" ]; then
    if [[ "$OS_TYPE" == "macos" ]]; then
        if ! chsh -s "$ZSH_PATH" 2>&1; then
            echo -e "${YELLOW}Warning: Could not set Zsh as default shell automatically.${NC}"
            echo -e "${YELLOW}Run manually: chsh -s ${ZSH_PATH}${NC}"
        fi
    else
        if ! sudo usermod --shell "$ZSH_PATH" "$USER" > /dev/null 2>&1; then
            if ! chsh -s "$ZSH_PATH"; then
                echo -e "${YELLOW}Warning: Could not set Zsh as default shell automatically.${NC}"
                echo -e "${YELLOW}Run manually: chsh -s ${ZSH_PATH}${NC}"
            fi
        fi
    fi
fi

echo -e "\n${GREEN}✔ Z-Shift Installation Complete! Please restart your terminal.${NC}"