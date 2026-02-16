#!/bin/bash

# =============================================================================
#  ███████╗      ███████╗██╗  ██╗██╗███████╗████████╗
#  ╚══███╔╝      ██╔════╝██║  ██║██║██╔════╝╚══██╔══╝
#    ███╔╝ █████╗███████╗███████║██║█████╗     ██║   
#   ███╔╝  ╚════╝╚════██║██╔══██║██║██╔══╝     ██║   
#  ███████╗      ███████╗██║  ██║██║██║         ██║   
#  ╚══════╝      ╚══════╝╚═╝  ╚═╝╚═╝╚═╝         ╚═╝   
# =============================================================================
#  Z-SHIFT: High-Performance Zsh + Gruvbox Bootstrap
#  Description: Automates Zinit, Starship, and Modern CLI Tooling.
#  Support: Debian/Ubuntu, Arch, Fedora, OpenSUSE, MacOS
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
            sudo pacman -Sy --noconfirm "${pkgs[@]}"
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
            echo "Please install the following packages manually: ${pkgs[*]}"
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
        
        # Add brew to path for the current session
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo -e "${GREEN}Homebrew is already installed.${NC}"
    fi
fi

# =============================================================================
# 2. SYSTEM DEPENDENCIES
# =============================================================================
echo -e "${YELLOW}Installing base dependencies...${NC}"

# Define base packages
COMMON_DEPS="git curl unzip zsh"

if [[ "$OS_TYPE" == "macos" ]]; then
    install_pkg git curl wget unzip zsh
else
    # Linux specific checks
    install_pkg wget gpg $COMMON_DEPS
fi

# =============================================================================
# 3. INSTALL STANDALONE TOOLS (Eza, Ripgrep)
# =============================================================================

# --- Eza Installation ---
echo -e "${YELLOW}Installing Eza (ls replacement)...${NC}"

if [[ "$DISTRO" == "ubuntu" ]] || [[ "$DISTRO" == "debian" ]] || [[ "$DISTRO" == "kali" ]] || [[ "$DISTRO" == "linuxmint" ]]; then
    # Debian/Ubuntu requires custom repo setup
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
else
    # Arch, Fedora, OpenSUSE, and MacOS have eza in standard/community repos
    install_pkg eza
fi

# --- Package Installation Snippet ---
# Note: Bat, Ripgrep and FZF are now handled by Zinit in .zshrc
# echo -e "${YELLOW}Installing Ripgrep...${NC}"
# install_pkg ripgrep

# =============================================================================
# 3.1 CLIPBOARD UTILITIES
# =============================================================================
echo -e "${YELLOW}Configuring Clipboard Utilities...${NC}"

if [[ "$OS_TYPE" == "macos" ]]; then
    echo -e "${GREEN}MacOS detected: pbcopy/pbpaste are built-in.${NC}"
else
    # Linux Logic: Check Display Server
    if [[ -n "$WAYLAND_DISPLAY" ]]; then
        echo -e "${BLUE}Wayland detected ($WAYLAND_DISPLAY). Installing wl-clipboard...${NC}"
        install_pkg wl-clipboard
    elif [[ -n "$DISPLAY" ]]; then
        echo -e "${BLUE}X11 detected ($DISPLAY). Installing xclip...${NC}"
        install_pkg xclip
    else
        echo -e "${YELLOW}No GUI display detected (Headless/SSH). Skipping clipboard tools.${NC}"
    fi
fi

# =============================================================================
# 4. CONFIGURE EZA THEMES
# =============================================================================
echo -e "${YELLOW}Setting up Eza Themes (Gruvbox Dark)...${NC}"
rm -rf ~/.config/eza-themes
git clone https://github.com/eza-community/eza-themes.git ~/.config/eza-themes

# Symlink theme
mkdir -p ~/.config/eza
ln -sf ~/.config/eza-themes/themes/gruvbox-dark.yml ~/.config/eza/theme.yml

# =============================================================================
# 5. STARSHIP CONFIGURATION
# =============================================================================
echo -e "${YELLOW}Setting up Starship Config...${NC}"

# Install Starship if missing
if ! command -v starship &> /dev/null; then
    if [[ "$OS_TYPE" == "macos" ]]; then
        install_pkg starship
    else
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
fi

# Generate the Gruvbox Rainbow config
mkdir -p ~/.config
echo -e "${BLUE}Generating ~/.config/starship.toml...${NC}"
starship preset gruvbox-rainbow -o ~/.config/starship.toml

# =============================================================================
# 6. FONTS (FiraCode Nerd Font)
# =============================================================================
echo -e "${YELLOW}Installing FiraCode Nerd Font...${NC}"

# Define Font Directory based on OS
if [[ "$OS_TYPE" == "macos" ]]; then
    FONT_DIR="$HOME/Library/Fonts"
else
    FONT_DIR="$HOME/.local/share/fonts"
fi

TEMP_DIR=$(mktemp -d)
mkdir -p "$FONT_DIR"

wget -q --show-progress -O "$TEMP_DIR/FiraCode.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip"
unzip -q "$TEMP_DIR/FiraCode.zip" -d "$TEMP_DIR"

# Move fonts (suppress errors if overwrite issues occur)
mv -f "$TEMP_DIR"/*.ttf "$FONT_DIR/" 2>/dev/null || true
rm -rf "$TEMP_DIR"

# Refresh font cache (Linux only)
if [[ "$OS_TYPE" == "linux" ]] && command -v fc-cache &> /dev/null; then
    echo "Rebuilding font cache..."
    fc-cache -f "$FONT_DIR"
fi

# =============================================================================
# 7. DOWNLOAD .ZSHRC
# =============================================================================
echo -e "${YELLOW}Downloading .zshrc from GitHub...${NC}"

# Backup existing .zshrc
if [ -f ~/.zshrc ]; then
    echo "Backing up current .zshrc to .zshrc.bak"
    mv ~/.zshrc ~/.zshrc.bak
fi

# Download
if wget -O ~/.zshrc "$ZSHRC_URL"; then
    echo -e "${GREEN}Downloaded .zshrc successfully.${NC}"
else
    echo -e "${RED}Failed to download .zshrc! Check the URL variable.${NC}"
    [ -f ~/.zshrc.bak ] && mv ~/.zshrc.bak ~/.zshrc
    exit 1
fi

# =============================================================================
# 8. FINALIZE
# =============================================================================
# Set Zsh as default
ZSH_PATH=$(which zsh)

# Add to /etc/shells if missing
if ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "Adding $ZSH_PATH to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi

# Change shell
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Changing default shell to Zsh..."
    if [[ "$OS_TYPE" == "macos" ]]; then
        chsh -s "$ZSH_PATH"
    else
        # Linux: try sudo usermod, fall back to chsh
        sudo usermod --shell "$ZSH_PATH" "$USER" || chsh -s "$ZSH_PATH"
    fi
fi

echo -e "\n${GREEN}✔ Z-Shift Installation Complete!${NC}"
echo -e "${YELLOW}➜ ACTION REQUIRED: Log out and log back in to activate the Zsh shell.${NC}"
echo -e "${YELLOW}➜ NOTE: Set your terminal font to 'FiraCode Nerd Font' to ensure icons render correctly.${NC}"