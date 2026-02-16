#!/bin/bash

# =============================================================================
#  ███████╗      ███████╗██╗  ██╗██╗███████╗████████╗
#  ╚══███╔╝      ██╔════╝██║  ██║██║██╔════╝╚══██╔══╝
#    ███╔╝ █████╗███████╗███████║██║█████╗     ██║   
#   ███╔╝  ╚════╝╚════██║██╔══██║██║██╔══╝     ██║   
#  ███████╗      ███████╗██║  ██║██║██║         ██║   
#  ╚══════╝      ╚══════╝╚═╝  ╚═╝╚═╝╚═╝         ╚═╝   
# =============================================================================
#  Z-SHIFT: High-Performance Zsh + Starship + Zinit installation script
# =============================================================================

# Exit immediately if a command exits with a non-zero status
set -e

# --- CONFIGURATION ---
ZSHRC_URL="https://raw.githubusercontent.com/0xdilshan/Z-SHIFT/main/.zshrc"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}>>> Initiating Z-Shift Environment Deployment...${NC}"

# =============================================================================
# 0. OS & PACKAGE MANAGER DETECTION
# =============================================================================
OS_TYPE="unknown"
DISTRO="unknown"

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
    DISTRO="macos"
elif [ -f /etc/os-release ]; then
    OS_TYPE="linux"
    # shellcheck disable=SC1091
    . /etc/os-release
    DISTRO=$ID
fi

echo -e "${BLUE}Detected OS: ${OS_TYPE} (${DISTRO})${NC}"

# Helper function to install packages based on distro
install_pkg() {
    local pkgs=("$@")
    echo -e "${YELLOW}Installing: ${pkgs[*]}...${NC}"

    case $DISTRO in
        ubuntu|debian|pop|kali|linuxmint)
            sudo apt update -y
            sudo apt install -y "${pkgs[@]}"
            ;;
        arch|manjaro|endeavouros)
            # Use --needed to skip up-to-date packages
            sudo pacman -Sy --noconfirm --needed "${pkgs[@]}"
            ;;
        fedora|rhel|centos)
            sudo dnf install -y "${pkgs[@]}"
            ;;
        opensuse*|suse)
            sudo zypper install -y "${pkgs[@]}"
            ;;
        macos)
            brew install "${pkgs[@]}"
            ;;
        *)
            echo -e "${RED}Unsupported distribution: $DISTRO${NC}"
            exit 1
            ;;
    esac
}

# =============================================================================
# 1. PRE-REQUISITES (Homebrew for MacOS)
# =============================================================================
if [[ "$OS_TYPE" == "macos" ]]; then
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
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
COMMON_DEPS="git curl unzip zsh"

if [[ "$OS_TYPE" == "macos" ]]; then
    install_pkg git curl wget unzip zsh
else
    # Linux specific checks: using 'gnupg' for cross-distro compatibility
    install_pkg wget gnupg $COMMON_DEPS
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
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            sudo apt update && sudo apt install -y eza
            ;;
        fedora)
            FEDORA_VERSION=$(rpm -E %fedora)
            if [ "$FEDORA_VERSION" -ge 42 ]; then
                echo -e "${YELLOW}:: Fedora $FEDORA_VERSION detected. Eza is not in official repos.${NC}"
                ARCH=$(uname -m)
                # Select correct binary based on architecture
                if [ "$ARCH" == "x86_64" ]; then
                    BINARY="eza_x86_64-unknown-linux-gnu.tar.gz"
                elif [ "$ARCH" == "aarch64" ]; then
                    BINARY="eza_aarch64-unknown-linux-gnu.tar.gz"
                else
                    echo -e "${RED}Unsupported arch for binary install: $ARCH${NC}"; exit 1
                fi
                curl -L "https://github.com/eza-community/eza/releases/latest/download/$BINARY" -o /tmp/eza.tar.gz
                tar -xzf /tmp/eza.tar.gz -C /tmp && sudo mv /tmp/eza /usr/local/bin/eza
                sudo chmod +x /usr/local/bin/eza && rm /tmp/eza.tar.gz
            else
                sudo dnf install -y eza
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
echo -e "${YELLOW}Setting up Eza Themes...${NC}"
rm -rf ~/.config/eza-themes
git clone https://github.com/eza-community/eza-themes.git ~/.config/eza-themes
mkdir -p ~/.config/eza
ln -sf ~/.config/eza-themes/themes/gruvbox-dark.yml ~/.config/eza/theme.yml

echo -e "${YELLOW}Setting up Starship Config...${NC}"
if ! command -v starship &> /dev/null; then
    if [[ "$OS_TYPE" == "macos" ]]; then
        install_pkg starship
    else
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
fi
mkdir -p ~/.config
starship preset gruvbox-rainbow -o ~/.config/starship.toml

# =============================================================================
# 5. FONTS (FiraCode Nerd Font)
# =============================================================================
if [ "$CI_ENV" = "true" ]; then
    echo -e "${YELLOW}>> CI Environment detected. Skipping Font Installation.${NC}"
else
    echo -e "${YELLOW}Installing FiraCode Nerd Font...${NC}"
    FONT_DIR="$HOME/.local/share/fonts"
    [[ "$OS_TYPE" == "macos" ]] && FONT_DIR="$HOME/Library/Fonts"
    
    TEMP_DIR=$(mktemp -d)
    mkdir -p "$FONT_DIR"
    wget -q --show-progress -O "$TEMP_DIR/FiraCode.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip"
    unzip -q "$TEMP_DIR/FiraCode.zip" -d "$TEMP_DIR"
    mv -f "$TEMP_DIR"/*.ttf "$FONT_DIR/" 2>/dev/null || true
    rm -rf "$TEMP_DIR"
    [[ "$OS_TYPE" == "linux" ]] && command -v fc-cache &> /dev/null && fc-cache -f "$FONT_DIR"
fi

# =============================================================================
# 6. DOWNLOAD .ZSHRC
# =============================================================================
echo -e "${YELLOW}Downloading .zshrc from GitHub...${NC}"
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.bak

if curl -fsSL -o ~/.zshrc "$ZSHRC_URL"; then
    echo -e "${GREEN}Downloaded .zshrc successfully.${NC}"
else
    echo -e "${RED}Failed to download .zshrc!${NC}"
    [ -f ~/.zshrc.bak ] && mv ~/.zshrc.bak ~/.zshrc
    exit 1
fi

# =============================================================================
# 7. FINALIZE
# =============================================================================
ZSH_PATH=$(which zsh)

if [ "$CI_ENV" = "true" ]; then
    echo -e "\n${GREEN}✔ CI Environment detected. Installation Verified!${NC}"
    exit 0
fi

if ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi

if [ "$SHELL" != "$ZSH_PATH" ]; then
    if [[ "$OS_TYPE" == "macos" ]]; then
        chsh -s "$ZSH_PATH"
    else
        sudo usermod --shell "$ZSH_PATH" "$USER" || chsh -s "$ZSH_PATH"
    fi
fi

echo -e "\n${GREEN}✔ Z-Shift Installation Complete!${NC}"