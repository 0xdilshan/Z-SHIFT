#!/bin/bash
# tests/local_test.sh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "Running Z-Shift Local Tests..."

# Check if files exist
REQUIRED_FILES=("install.sh" ".zshrc" "README.md")
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "../$file" ] || [ -f "$file" ]; then
        echo -e "[${GREEN}PASS${NC}] File $file exists"
    else
        echo -e "[${RED}FAIL${NC}] File $file missing"
        exit 1
    fi
done

# Syntax Check (Zsh)
if command -v zsh >/dev/null; then
    # We look for .zshrc in parent dir or current dir
    ZSHRC_PATH=""
    [ -f ".zshrc" ] && ZSHRC_PATH=".zshrc"
    [ -f "../.zshrc" ] && ZSHRC_PATH="../.zshrc"
    
    if zsh -n "$ZSHRC_PATH"; then
        echo -e "[${GREEN}PASS${NC}] .zshrc syntax is valid"
    else
        echo -e "[${RED}FAIL${NC}] .zshrc contains syntax errors"
        exit 1
    fi
else
    echo -e "[${RED}WARN${NC}] zsh not installed, skipping syntax check"
fi

# Shellcheck (Bash)
if command -v shellcheck >/dev/null; then
    INSTALL_PATH=""
    [ -f "install.sh" ] && INSTALL_PATH="install.sh"
    [ -f "../install.sh" ] && INSTALL_PATH="../install.sh"

    # We exclude warning SC2181 (checking $? directly) as it's common in install scripts
    if shellcheck -e SC2181 "$INSTALL_PATH"; then
        echo -e "[${GREEN}PASS${NC}] install.sh passed shellcheck"
    else
        echo -e "[${RED}FAIL${NC}] install.sh failed shellcheck"
        exit 1
    fi
else
    echo -e "[${RED}WARN${NC}] shellcheck not installed, skipping linting"
fi

echo "All local checks passed."