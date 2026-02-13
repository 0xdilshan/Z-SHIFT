#!/bin/bash

# =============================================================================
#  ███████╗      ███████╗██╗  ██╗██╗███████╗████████╗
#  ╚══███╔╝      ██╔════╝██║  ██║██║██╔════╝╚══██╔══╝
#    ███╔╝ █████╗███████╗███████║██║█████╗     ██║   
#   ███╔╝  ╚════╝╚════██║██╔══██║██║██╔══╝     ██║   
#  ███████╗      ███████║██║  ██║██║██║        ██║   
#  ╚══════╝      ╚══════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   
# =============================================================================
#  Z-SHIFT: High-Performance Zsh + Gruvbox Bootstrap
#  Description: Automates Zinit, Starship, and Modern CLI Tooling.
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
NC='\033[0m' # No Color

echo -e "${CYAN}>>> Initiating Z-Shift Environment Deployment...${NC}"

# =============================================================================
# 1. SYSTEM DEPENDENCIES
# =============================================================================
echo -e "${YELLOW}Installing base dependencies (git, curl, unzip, zsh)...${NC}"
sudo apt update
sudo apt install -y wget gpg git curl unzip zsh xclip

# =============================================================================
# 2. INSTALL STANDALONE TOOLS
# =============================================================================
# These are tools your .zshrc expects to exist on the system (eza, bat, rg).

# --- Install Eza ---
echo -e "${YELLOW}Installing Eza...${NC}"
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

# --- Install Bat & Ripgrep ---
echo -e "${YELLOW}Installing Bat and Ripgrep...${NC}"
sudo apt install -y bat ripgrep

# Fix 'bat' on Ubuntu (symlink batcat -> bat)
if command -v batcat &> /dev/null; then
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/batcat ~/.local/bin/bat
fi

# =============================================================================
# 3. CONFIGURE EZA THEMES
# =============================================================================
echo -e "${YELLOW}Setting up Eza Themes (Gruvbox Dark)...${NC}"
rm -rf ~/.config/eza-themes
git clone https://github.com/eza-community/eza-themes.git ~/.config/eza-themes

# Symlink theme
mkdir -p ~/.config/eza
ln -sf ~/.config/eza-themes/themes/gruvbox-dark.yml ~/.config/eza/theme.yml

# =============================================================================
# 4. STARSHIP CONFIGURATION
# =============================================================================
echo -e "${YELLOW}Setting up Starship Config...${NC}"

# We install a temporary system-level starship binary to generate the config file.
# Your .zshrc will later install its own isolated version via Zinit, which is fine.
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Generate the Gruvbox Rainbow config
mkdir -p ~/.config
echo -e "${BLUE}Generating ~/.config/starship.toml...${NC}"
starship preset gruvbox-rainbow -o ~/.config/starship.toml

# =============================================================================
# 5. FONTS (FiraCode Nerd Font)
# =============================================================================
echo -e "${YELLOW}Installing FiraCode Nerd Font...${NC}"
FONT_DIR="$HOME/.local/share/fonts"
TEMP_DIR=$(mktemp -d)
mkdir -p "$FONT_DIR"

wget -q --show-progress -O "$TEMP_DIR/FiraCode.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip"
unzip -q "$TEMP_DIR/FiraCode.zip" -d "$TEMP_DIR"
mv "$TEMP_DIR"/*.ttf "$FONT_DIR/"
rm -rf "$TEMP_DIR"

# Refresh font cache
if command -v fc-cache &> /dev/null; then
    echo "Rebuilding font cache..."
    fc-cache -f "$FONT_DIR"
fi

# =============================================================================
# 6. DOWNLOAD .ZSHRC
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
    # Restore backup if download failed
    [ -f ~/.zshrc.bak ] && mv ~/.zshrc.bak ~/.zshrc
    exit 1
fi

# =============================================================================
# 7. FINALIZE
# =============================================================================
# Set Zsh as default
# Define Zsh path
ZSH_PATH=$(which zsh)

# Ensure Zsh is in /etc/shells
if ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "Adding $ZSH_PATH to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi

# Change shell (try non-interactive first)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Changing default shell to Zsh..."
    # Attempt to change shell using sudo (will ask for password once)
    sudo usermod --shell "$ZSH_PATH" "$USER" || chsh -s "$ZSH_PATH"
fi

echo -e "\n${GREEN}✔ Z-Shift Installation Complete!${NC}"
echo -e "${YELLOW}➜ ACTION REQUIRED: Log out and log back in to activate the Zsh shell.${NC}"
echo -e "${YELLOW}➜ NOTE: Set your terminal font to 'FiraCode Nerd Font' to ensure icons render correctly.${NC}"