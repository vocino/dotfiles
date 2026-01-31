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

# Custom prompt: path with ~ for home prefix, optional git branch, $ on next line
set_prompt() {
    local current_path="$PWD"
    # Use HOME for shortening (Git Bash usually sets it to Unix-style, e.g. /c/Users/you)
    local home="${HOME:-$USERPROFILE}"
    if [[ "$current_path" == "$home" ]]; then
        current_path="~"
    elif [[ "$current_path" == "$home"/* ]]; then
        current_path="~${current_path#$home}"
    fi
    local branch=""
    if command -v git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
        branch=$(git branch --show-current 2>/dev/null)
        [[ -n "$branch" ]] && branch=" $branch"
    fi
    # Cyan path, green branch; $ on next line (Git Bash supports \033[36m, \033[32m)
    PS1='\[\033[36m\]'"$current_path"'\[\033[32m\]'"$branch"'\[\033[0m\]\n$ '
}
PROMPT_COMMAND='set_prompt'
