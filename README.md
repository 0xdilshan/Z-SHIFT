# 🐚 Z-SHIFT

![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat-square&logo=linux&logoColor=black)
![macOS](https://img.shields.io/badge/OS-macOS-000000?style=flat-square&logo=apple&logoColor=white)
![Zsh](https://img.shields.io/badge/zsh-%23333333.svg?style=flat-square&logo=zsh&logoColor=white)
![Bash](https://img.shields.io/badge/bash-%234EAA25.svg?style=flat-square&logo=gnu-bash&logoColor=white)
![Homebrew](https://img.shields.io/badge/Homebrew-%23FBB040?style=flat-square&logo=homebrew&logoColor=black)
![Starship](https://img.shields.io/badge/starship-%23DD0B78.svg?style=flat-square&logo=starship&logoColor=white)
![Gruvbox](https://img.shields.io/badge/Theme-Gruvbox-%23d79921?style=flat-square)
![Zoxide](https://img.shields.io/badge/Nav-Zoxide-%23ff5555?style=flat-square&logo=rust&logoColor=white)
![Eza](https://img.shields.io/badge/List-Eza-%2350fa7b?style=flat-square)
![Bat](https://img.shields.io/badge/Cat-Bat-%23458588?style=flat-square)
![Fd](https://img.shields.io/badge/Find-Fd-%238ec07c?style=flat-square&logo=rust&logoColor=white)
![Fzf](https://img.shields.io/badge/Fuzzy-Fzf-%23d3869b?style=flat-square)
![Ripgrep](https://img.shields.io/badge/Search-Ripgrep-%233E8BFF?style=flat-square&logo=rust&logoColor=white)
![Tealdeer](https://img.shields.io/badge/Docs-Tealdeer-%2320B2AA?style=flat-square&logo=rust&logoColor=white)
![Nerd Fonts](https://img.shields.io/badge/Nerd_Fonts-%23333333.svg?style=flat-square&logo=nerdfonts&logoColor=white)
![Git](https://img.shields.io/badge/git-%23F05033.svg?style=flat-square&logo=git&logoColor=white)


**Z-SHIFT** is an automated installer script designed to transform a stock `Z-shell` (`ZSH`) into a high-performance + aesthetically pleasing development environment.

It handles the heavy lifting of installing a modern plugin manager, configuring a lightning-fast prompt and setting up the next generation of CLI tools in a single command.

<div align="center">

[![asciicast](https://asciinema.org/a/qVjPp58itF6FGrI6.svg)](https://asciinema.org/a/qVjPp58itF6FGrI6)

 **🚅 High-Performance Zsh + 🌸Gruvbox + ⚡ Zinit + Extra Goodies Installer**

</div>

------------

## Table of contents

- [✨ Features](#-features)
- [💿 Installation](#-installation)
      + [One-Line Install](#one-line-install)
      + [Manual Install](#manual-install)
- [📦 Plugin Ecosystem](#-plugin-ecosystem)
- [🗺️ Roadmap](#-roadmap)
- [🤝 Contributing](#-contributing)
- [📝 License](#-license)

------------


## ✨ Features

- ***⚡ Zinit Plugin Manager:*** Uses Turbo mode for non-blocking, rapid plugin loading. [https://github.com/zdharma-continuum/zinit]

- ***🚀 Starship Prompt:*** A minimal, blazing-fast, and infinitely customizable prompt for any shell. [https://starship.rs/]

- ***🛠 Modern CLI Arsenal:*** Automatically installs and configures:

  - **bat:** A `cat` clone with syntax highlighting and Git integration. [https://github.com/sharkdp/bat]
  - **eza:** A modern & maintained replacement for `ls` with colors and icons. [https://github.com/eza-community/eza]
  - **fd:** A simple & fast and user-friendly alternative to `find`. [https://github.com/sharkdp/fd]
  - **fzf:** A general-purpose command-line fuzzy finder for lightning-fast file and history navigation. [https://github.com/junegunn/fzf]
  - **ripgrep:** A line-oriented search tool that respects .gitignore and is faster than grep. [https://github.com/BurntSushi/ripgrep]
  - **tealdeer:** A fast implementation of `tldr;` (simplified man pages). [https://github.com/tealdeer-rs/tealdeer]
  - **zoxide:** A smarter `cd` command that learns your habits. [https://github.com/ajeetdsouza/zoxide]

- ***⌨️ Pre-Configured Aliases:*** Includes a suite of intelligent aliases for common tasks to boost productivity immediately. You can use `alias` command to list all the aliases.

------------


## 💿 Installation

#### One-Line Install

You can set up your environment by running this command in your terminal:


```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/0xdilshan/Z-SHIFT/main/install.sh)"
``` 

***⚠️ Please log out and log back in to apply the changes. Additionally, ensure your terminal emulator's font is set to `FiraCode Nerd Font` (or any Nerd Font) so that icons and ligatures display correctly.***


#### Manual Install

If you prefer to download the script manually:

```
curl -O https://raw.githubusercontent.com/0xdilshan/Z-SHIFT/main/install.sh
chmod +x install.sh
./install.sh
```

------------

## 📦 Plugin Ecosystem

**🐚 Z-Shift** comes pre-loaded with a curated selection of the best Zsh plugins, lazy-loaded for speed:

- ### Core Libraries (OMZ)

  - **Git:** Essential git aliases and functions.
  - **History:** optimized history settings.
  - **Directories:** Navigation shortcuts and stack management.
  - **Completion:** Robust tab completion.
  - **Clipboard:** Cross-platform clipboard integration.

- ### Power Utilities

  - **extract:** One command to decompress almost any archive file (`.tar`, `.zip`, `.gz`, etc.).
  - **sudo:** Double-tap `ESC` to prepend `sudo` to the current or previous command.
  - **zsh-you-should-use:** Reminds you if there is an existing alias for the command you just typed.

------------

## 🗺️ Roadmap

- [x] Safety Backup: Automatically backup existing `.zshrc`
- [x] Multi-Distro Support: Add package manager detection (`pacman`, `dnf`, `zypper`) for Arch, Fedora, and OpenSUSE.
- [x] MacOS Support: Add `Homebrew` support for macOS users.
- [ ] Interactive Menu: Allow users to select themes for `starship` and `eza`.
- [ ] Uninstaller Script: Create a `uninstall.sh` to revert changes and restore the previous shell environment.
- [ ] Docker Test Container: Provide a `Dockerfile` so users can test the setup safely in a container before applying it to their host machine.
- [ ] Self-Updater: Add a command (e.g., `zshift-update`) to pull the latest aliases and config changes.


------------

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues](https://github.com/0xdilshan/Z-SHIFT/issues) page.

------------

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.