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
![Zsh Interactive Prompt Time](https://img.shields.io/badge/Startup_Time-%3C69ms-success?style=flat-square&logo=zsh)
![Input Lag](https://img.shields.io/badge/Input_Lag-~3ms-blue?style=flat-square)
[![Z-Shift CI](https://github.com/0xdilshan/Z-SHIFT/actions/workflows/ci.yml/badge.svg)](https://github.com/0xdilshan/Z-SHIFT/actions/workflows/ci.yml)


**Z-SHIFT** is an automated installer script designed to transform a stock `Z-shell` (`ZSH`) into a high-performance + aesthetically pleasing development environment.

It handles the heavy lifting of installing a modern plugin manager, configuring a lightning-fast prompt and setting up the next generation of CLI tools in a single command.

<div align="center">

<a href="https://asciinema.org/a/OxCngXRZiIHzFFLL" target="_blank"><img src="https://asciinema.org/a/OxCngXRZiIHzFFLL.svg" /></a>

 ***🚅 High-Performance Zsh + 🌸Gruvbox + ⚡ Zinit + Extra Goodies Installer***
 
 ***⚡ ~20ms core startup time with a total time-to-prompt of under 69ms.***

</div>

------------

## Table of contents

- [✨ Features](#-features)
- [💿 Installation](#-installation)
      + [One-Line Install](#one-line-install)
      + [Manual Install](#manual-install)
- [📥 Update z-shift](#-update)
- [🗑️ Uninstall Z-SHIFT](#uninstall-z-shift)
- [🎨 Change Themes](#-change-themes)
- [📦 Plugin Ecosystem](#-plugin-ecosystem)
- [🏷️ Persistent Customization](#️-persistent-customization)
- [⚡ Performance](#-performance)
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


```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/0xdilshan/Z-SHIFT/main/install.sh)"
``` 

***⚠️ Please log out and log back in to apply the changes. Additionally, ensure your terminal emulator's font is set to `FiraCode Nerd Font` (or any Nerd Font) so that icons and ligatures display correctly.***


#### Manual Install

If you prefer to download the script manually:

```bash
curl -O https://raw.githubusercontent.com/0xdilshan/Z-SHIFT/main/install.sh
chmod +x install.sh
./install.sh
```
------------

## 📥 Update

You can easily update to latest .zshrc config using alias in the below.

```bash
zsu
```


------------

## Uninstall Z-SHIFT


```bash
curl -O https://raw.githubusercontent.com/0xdilshan/Z-SHIFT/main/uninstall.sh
chmod +x uninstall.sh
./uninstall.sh
```

------------

## 🎨 Change Themes

Don't like the defaults? You can switch between **12 Starship presets** and **17 Eza color schemes** instantly using the interactive theme manager.

#### Run Theme Switcher
You can launch the menu directly from the web without downloading anything:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/0xdilshan/Z-SHIFT/main/theme.sh)"
```

------------

## 📦 Plugin Ecosystem

**🐚 Z-Shift** comes pre-loaded with a curated selection of the best Zsh plugins, lazy-loaded for speed:

- ### Core Libraries & Plugins

  - **Git:** Essential git aliases.
  - **History:** Optimized history settings for better search and recall.
  - **Directories:** Navigation shortcuts and directory stack management.
  - **Completion:** Tab completion enhanced with `zsh-completions` & `fzf-tab`.
  - **Syntax Highlighting:** Real-time syntax highlighting via `fast-syntax-highlighting`.
  - **Autosuggestions:** Fish-style inline suggestions powered by `zsh-autosuggestions`.
  - **Clipboard:** Cross-platform clipboard integration.

<details open>

<summary>clip command usage examples:</summary>

**Copying to the clipboard**

```bash
# Copy a string directly
echo "This is now in my clipboard" | clip

# Copy the contents of a file
cat ~/.ssh/id_rsa.pub | clip

# Copy the output of a command
ls -la | clip
```

**Pasting from the clipboard**

```bash
# Paste clipboard contents directly into the terminal
clip

# Paste clipboard contents into a new file
clip > pasted_data.txt

# Pipe clipboard contents into another command
clip | grep "error"
```

**Advanced Chaining**

```bash
# Read clipboard, convert to lowercase, and copy the result back to clipboard
clip | tr 'A-Z' 'a-z' | clip

# Format JSON currently in the clipboard and copy it back
clip | jq . | clip
```

</details>

- ### Power Utilities

  - **extract:** One command to decompress almost any archive file (`.tar`, `.zip`, `.gz`, etc.).
  - **sudo:** Double-tap `ESC` to prepend `sudo` to the current or previous command.
  - **zsh-you-should-use:** Reminds you if there is an existing alias for the command you just typed.

------------

## 🏷️ Persistent Customization

Users can now save persistent `LOCAL CUSTOMIZATION` using `~/.zshrc.local` file. Also you can override the update source by setting `ZSHIFT_CUSTOM_URL` in environment or `~/.zshrc.local`, making it easier for folks running forks to stay in sync with their own repos.

```bash
nano ~/.zshrc.local
export ZSHIFT_CUSTOM_URL="https://raw.githubusercontent.com/username/repo-name/branch-name/.zshrc"
```

------------

## ⚡ Performance

Optimized for speed and low latency. Benchmarked using [zsh-bench](https://github.com/romkatv/zsh-bench).

| Metric | Time |
| :--- | :--- |
| **First Prompt** | `~69 ms` 🚀 |
| **Command Lag** | `~55 ms` |
| **Input Lag** | `~3 ms` |

![benchmark](benchmark/z-shift-bench.webp)

*Achieved by replacing heavy OMZ libraries with Starship and selectively loading plugins using Optimized Zinit plugin manager.*

------------

## 🗺️ Roadmap

- [x] Safety Backup: Automatically backup existing `.zshrc`
- [x] Multi-Distro Support: Add package manager detection (`pacman`, `dnf`, `zypper`) for Arch, Fedora, and OpenSUSE.
- [x] MacOS Support: Add `Homebrew` support for macOS users.
- [x] Uninstaller Script: Create a `uninstall.sh` to revert changes and restore the previous shell environment.

~~- [ ] Docker Test Container: Provide a `Dockerfile` so users can test the setup safely in a container before applying it to their host machine.~~

- [x] CI Tests: Add Docker + Github Actions CI workflow to test releases.
- [x] Self-Updater: Add a command (e.g., `zshift-update`) to pull the latest aliases and config changes.
- [x] Interactive Menu: Allow users to select themes for `starship` and `eza`.


------------

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues](https://github.com/0xdilshan/Z-SHIFT/issues) page.

------------

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.