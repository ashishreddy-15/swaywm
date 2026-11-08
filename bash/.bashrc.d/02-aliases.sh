# ============================================================
# 02-aliases.sh — All aliases
# ============================================================

# --- DNF Package Manager Shortcuts ---
alias din='sudo dnf install -y'           # Install package(s)
alias dup='sudo dnf upgrade -y'           # Upgrade all packages
alias drm='sudo dnf remove -y'           # Remove package(s)
alias dse='dnf search'                   # Search packages (no sudo)
alias dinfo='dnf info'                   # Show package info
alias dlist='dnf list installed'         # List installed packages
alias dclean='sudo dnf autoremove -y && sudo dnf clean all'  # Clean up
alias dcheck='dnf check-update'          # Check for updates (no sudo)

# --- Modern Tool Replacements (safe: fallback if not installed) ---
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first --color=always'
    alias ll='eza -la --icons --git --group-directories-first --color=always'
    alias la='eza -a --icons --group-directories-first --color=always'
    alias lt='eza --tree --icons -L 2 --group-directories-first'
    alias ltt='eza --tree --icons -L 3 --group-directories-first'
else
    alias ls='ls --color=auto'
    alias ll='ls -lhA --color=auto'
    alias la='ls -A --color=auto'
fi

if command -v bat &>/dev/null; then
    alias cat='bat --style=plain --paging=never'
    alias catp='bat --style=full'          # cat with paging & full style
fi

# grep/find stay standard (their flags differ from rg/fd, so copied
# commands keep working); call rg and fd directly.
alias grep='grep --color=auto'

if command -v dust &>/dev/null; then
    alias du='dust'
fi

if command -v procs &>/dev/null; then
    alias ps='procs'
fi

# --- Navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# --- Safety Nets ---
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'       # make parents + verbose

# --- Shortcuts ---
alias q='exit'
alias c='clear'
alias h='history'
alias jl='jobs -l'                 # (j is zoxide jump, see 04-zoxide.sh)
alias bashrc='${EDITOR:-nano} ~/.bashrc'
alias bsrc='${EDITOR:-nano} ~/.bashrc.d/'

# --- Disk & System ---
alias df='df -h'
alias free='free -h'
alias ports='ss -tlnp'
alias localip="ip route get 1 | awk '{print \$NF;exit}'"
alias psg='ps aux | grep -v grep | grep'    # psg firefox

# --- Git Shortcuts ---
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -m'
alias gca='git commit --amend --no-edit'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git log --oneline --graph --decorate -20'
alias gll='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gb='git branch -vv'
alias gba='git branch -avv'
alias gst='git stash'
alias gstp='git stash pop'
alias gfetch='git fetch --all --prune'
alias gpull='git pull --rebase'

# --- Misc ---
alias week='date +%V'                      # current week number
alias timestamp='date +%Y%m%d_%H%M%S'
alias path='echo "$PATH" | tr ":" "\n" | nl'  # pretty print PATH
alias show-colors='for i in {0..255}; do printf "\x1b[38;5;%dm %3d\e[0m" $i $i; done; echo'
