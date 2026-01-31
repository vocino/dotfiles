# Git Bash profile for Windows 11 Pro
# This file is symlinked from ~/dotfiles/git-bash/.bashrc

# Dotfiles paths (Git Bash on Windows uses USERPROFILE for HOME when set)
DOTFILES_ROOT="${USERPROFILE:-$HOME}/dotfiles"
SECRETS_DIR="$DOTFILES_ROOT/secrets"

# Load secrets from local dotenv files (ignored by git) - always, so scripts get env too
if [[ -d "$SECRETS_DIR" ]]; then
    for f in "$SECRETS_DIR"/.env.*; do
        [[ -f "$f" ]] || continue
        [[ "$f" == *.example ]] && continue
        while IFS= read -r line || [[ -n "$line" ]]; do
            line="${line%%#*}"
            line="${line#"${line%%[![:space:]]*}"}"
            line="${line%"${line##*[![:space:]]}"}"
            [[ -z "$line" ]] && continue
            if [[ "$line" == export\ * ]]; then
                line="${line#export }"
            fi
            if [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
                export "$line"
            fi
        done < "$f"
    done
fi

# Only run interactive setup (aliases, prompt) in interactive shells
[[ $- != *i* ]] && return

# UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Common aliases
alias ll='ls -la'
alias la='ls -la'
alias grep='grep --color=auto'

# Git shortcuts (same semantics as PowerShell profile)
if command -v git &>/dev/null; then
    gst() { git status "$@"; }
    gco() { git checkout "$@"; }
    gaa() { git add --all "$@"; }
    gcm() { git commit -m "$*"; }
    gp() { git push "$@"; }
    gl() { git pull "$@"; }
    gstc() { git status --short "$@"; }
fi

# npm/node helpers (same as PowerShell profile)
if command -v npm &>/dev/null; then
    nr() { npm run "$@"; }
    ni() { npm install "$@"; }
    nid() { npm install -D "$@"; }
    nu() { npm update "$@"; }
fi

# Navigate to dotfiles directory
dotfiles() { cd "$DOTFILES_ROOT" || return; }

# Reload profile
reload() { source ~/.bashrc; }

# Open Cursor in current directory
cursor() {
    if command -v cursor &>/dev/null; then
        cursor .
    else
        echo "Cursor CLI not found. Install from https://cursor.sh"
    fi
}

# Custom prompt: path (or ~ when in HOME) in color, then " > "
set_prompt() {
    local current_path="$PWD"
    if [[ "$current_path" == "$HOME" || "$current_path" == "$USERPROFILE" ]]; then
        current_path="~"
    fi
    # Cyan for path (Git Bash supports \033[36m)
    PS1='\[\033[36m\]'"$current_path"'\[\033[0m\] > '
}
PROMPT_COMMAND='set_prompt'
