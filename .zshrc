# =============================================================================
# 1. ZINIT INSTALLER
# =============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname "$ZINIT_HOME")"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# =============================================================================
# 2. LOAD STARSHIP PROMPT
# =============================================================================
zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" \
          src"init.zsh"
zinit load starship/starship

# =============================================================================
# 3. PLUGINS
# =============================================================================

# --- Core Libraries & Utilities ---
zinit wait lucid for \
    OMZL::clipboard.zsh \
    OMZP::extract \
    OMZP::sudo \
    OMZP::git \
    MichaelAquilina/zsh-you-should-use

# --- BAT (Cat replacement) ---
zinit ice as"program" from"gh-r" mv"bat* -> bat" pick"bat/bat" wait lucid
zinit load sharkdp/bat

# --- EZA (Smarter ls) ---
zinit ice wait lucid as"program" from"gh-r" pick"eza" \
    atclone"./eza --completions zsh > _eza" \
    atpull"%atclone"
zinit load eza-community/eza

# --- FD (Find replacement) ---
zinit ice as"program" from"gh-r" mv"fd* -> fd" pick"fd/fd" wait lucid
zinit load sharkdp/fd

# --- FZF (Fuzzy Finder) ---
zinit ice as"program" from"gh-r" wait lucid \
    atclone"./fzf --zsh > init.zsh" \
    atpull"%atclone" \
    src"init.zsh" \
    atload'export FZF_DEFAULT_COMMAND="fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"; export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"'
zinit light junegunn/fzf

# --- RIPGREP (Grep replacement) ---
zinit ice as"program" from"gh-r" mv"ripgrep* -> ripgrep" pick"ripgrep/rg" wait lucid
zinit load BurntSushi/ripgrep

# --- TLDR (Tealdeer) ---
zinit ice wait lucid as"command" from"gh-r" mv"tealdeer* -> tldr" pick"tldr"
zinit load tealdeer-rs/tealdeer

# --- Zoxide (Smarter cd) ---
zinit ice as"program" from"gh-r" pick"zoxide" \
    atclone"./zoxide init zsh --cmd cd > init.zsh" \
    atpull"%atclone" \
    src"init.zsh" nocompile"init.zsh"
zinit light ajeetdsouza/zoxide

# --- Completions, Suggestions & Highlighting ---

# Load extra completions first
zinit wait lucid blockf atpull"zinit creinstall -q ." for \
    zsh-users/zsh-completions


# IMPORTANT ORDER:
# compinit -> fzf-tab -> syntax-highlighting -> autosuggestions

zinit wait lucid \
    atinit"zicompinit; zicdreplay" \
    atload'compdump="${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump}";
            [[ ! -s "${compdump}.zwc" || "$compdump" -nt "${compdump}.zwc" ]] &&
            zcompile "$compdump" &!' \
    for Aloxaf/fzf-tab \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions

# =============================================================================
# 4. CONFIGURATION
# =============================================================================

# Deduplicate the PATH array
typeset -U PATH path

HISTSIZE=20000
SAVEHIST=20000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt AUTO_CD

# --- Completion Styling (Replaces OMZL::completion.zsh) ---
# Case-insensitive matching (a matches A)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
# Colored completion list
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# Menu selection (navigate with arrow keys)
zstyle ':completion:*:*:*:*:*' menu select
# Group results by category
zstyle ':completion:*' group-name ''
zstyle ':completion:::::' completer _expand _complete _ignored _approximate

# --- fzf-tab Styling ---
# Set descriptions format to enable group support in fzf-tab
zstyle ':completion:*:descriptions' format '[%d]'
# Preview directory contents with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always -- "$realpath"'
# Switch completion groups using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# =============================================================================
# 5. ALIASES & FUNCTIONS
# =============================================================================

# --- Navigation ---
alias -- -='cd -'
alias ..='cd ..'
alias ...='cd ../..'
alias md='mkdir -p'

# --- Quick Edits ---
# Config shortcuts
_edit() {
  local editor
  editor=$(command -v nano 2>/dev/null || command -v vi)
  "$editor" "$@"
}

sconf() { _edit "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml" }
zconf() { _edit "${ZDOTDIR:-$HOME}/.zshrc" }
alias reload='exec zsh'

# --- Human readable disk usage ---
alias df='df -h'
alias du='du -h -d 1' # Disk usage depth 1

# --- Zinit & Maintenance ---
alias zini='zinit'
alias zup='zinit self-update && zinit update --parallel && zinit cclear && tldr --update'
alias zclean='zinit cclear && zinit delete --clean'

# This avoids a noisy warning if the aliases were never set.

(( ${+aliases[zi]}  )) && unalias zi
(( ${+aliases[zpl]} )) && unalias zpl
(( ${+aliases[zplg]})) && unalias zplg

# --- Eza (The ls replacement) ---
if [[ -n "${commands[eza]}" ]]; then
    alias ls='eza --icons --group-directories-first --git'
    alias l='eza -lh --icons --git --group-directories-first'
    alias ll='eza -l --icons --git --group-directories-first'
    alias la='eza -lah --icons --git --group-directories-first'
    alias lt='eza --tree --level=2 --icons'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah'
fi

# --- The Modern Toolset ---
alias cat='bat -p --paging=never'
alias catp='bat'
alias grep='grep --color=auto'
alias h='tldr'
alias hup='tldr --update'

# Smart Help Function
help() {
    tldr "$@" || man "$@"
}

# =============================================================================
# 6. KEYBINDINGS
# =============================================================================
bindkey -e

# Use terminfo for terminal-agnostic up/down arrow bindings
if [[ -n "${terminfo[kcuu1]}" ]]; then
  bindkey "${terminfo[kcuu1]}" up-line-or-search
fi
if [[ -n "${terminfo[kcud1]}" ]]; then
  bindkey "${terminfo[kcud1]}" down-line-or-search
fi

# =============================================================================
# Z-SHIFT SELF-MAINTENANCE
# =============================================================================

zshift-update() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local BLUE='\033[0;34m'
    local YELLOW='\033[1;33m'
    local NC='\033[0m'

    local DATE_STAMP BACKUP_FILE TEMP_ZSHRC UPDATE_URL
    DATE_STAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$HOME/.zshrc.zshift_${DATE_STAMP}.bak"
    TEMP_ZSHRC="$(mktemp)"

    UPDATE_URL="${ZSHIFT_CUSTOM_URL:-https://raw.githubusercontent.com/0xdilshan/Z-SHIFT/main/.zshrc}"

    echo -e "${BLUE}:: Initiating Z-Shift Update...${NC}"

    if ! curl -fsSL -o "$TEMP_ZSHRC" "$UPDATE_URL"; then
        echo -e "${RED}Error: Failed to download update.${NC}"
        rm -f "$TEMP_ZSHRC"
        return 1
    fi

    # Integrity Check
    if ! grep -q "zdharma-continuum/zinit" "$TEMP_ZSHRC"; then
        echo -e "${RED}Error: Downloaded file is invalid.${NC}"
        rm -f "$TEMP_ZSHRC"
        return 1
    fi

    if [ -f "$HOME/.zshrc" ]; then
        echo -e "${YELLOW}:: Backing up current config to: ${NC}$BACKUP_FILE"
        cp "$HOME/.zshrc" "$BACKUP_FILE"
    fi

    # Warn the user if their current .zshrc differs from the backup,
    if [ -f "$BACKUP_FILE" ] && ! diff -q "$HOME/.zshrc" "$BACKUP_FILE" > /dev/null 2>&1; then
        echo -e "${YELLOW}!! Warning: Your .zshrc has local modifications.${NC}"
        echo -e "${YELLOW}   These will be replaced. Move personal config to ~/.zshrc.local to preserve it.${NC}"
        echo -ne "${YELLOW}   Continue anyway? [y/N]: ${NC}"
        read -r REPLY
        if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}:: Update cancelled.${NC}"
            rm -f "$TEMP_ZSHRC"
            return 0
        fi
    fi

    mv "$TEMP_ZSHRC" "$HOME/.zshrc"
    echo -e "${GREEN}:: Configuration file updated.${NC}"

    if command -v zinit >/dev/null 2>&1; then
        echo -e "${BLUE}:: Updating Zinit and Plugins...${NC}"
        if ! (zinit self-update && zinit update --parallel); then
            echo -e "${RED}!! Plugin update failed. Rolling back...${NC}"
            if [ -f "$BACKUP_FILE" ]; then
                mv "$BACKUP_FILE" "$HOME/.zshrc"
            fi
            return 1
        fi
    fi

    echo -e "\n${GREEN}✔ Z-Shift Update Complete! Restarting shell...${NC}"
    exec zsh
}

alias zsu='zshift-update'

# =============================================================================
# 7. BYTE-COMPILATION & LOCAL CUSTOMIZATIONS
# =============================================================================
ZSHRC_DIR="${ZDOTDIR:-$HOME}"

auto_compile() {
    local file="$1"
    if [[ -f "$file" && ( ! -s "${file}.zwc" || "$file" -nt "${file}.zwc" ) ]]; then
        zcompile "$file" &!
    fi
}

# Compile the main .zshrc
auto_compile "$ZSHRC_DIR/.zshrc"

# Compile and source the local customizations (if they exist)
if [[ -f "$ZSHRC_DIR/.zshrc.local" ]]; then
    auto_compile "$ZSHRC_DIR/.zshrc.local"
    source "$ZSHRC_DIR/.zshrc.local"
fi