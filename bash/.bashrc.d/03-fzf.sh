# ============================================================
# 03-fzf.sh — fzf fuzzy finder config & functions
# ============================================================

# Skip if fzf is not installed
command -v fzf &>/dev/null || return 0

# --- Core fzf options ---
export FZF_DEFAULT_OPTS="
    --height=50%
    --layout=reverse
    --border=rounded
    --info=inline
    --prompt='❯ '
    --pointer='▶'
    --marker='✓'
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-u:preview-page-up'
    --bind='ctrl-d:preview-page-down'
    --bind='ctrl-a:select-all'
    --bind='ctrl-y:execute-silent(echo -n {+} | wl-copy)'
    --color=fg:#e6e8e1,hl:#6fa3b8,fg+:#e6e8e1,bg+:#222820,hl+:#6fa3b8,gutter:-1
    --color=info:#8c9384,prompt:#6fa3b8,pointer:#6fa3b8,marker:#6fa3b8,spinner:#8c9384,header:#8c9384
    --color=border:#2e342a,separator:#2e342a,scrollbar:#2e342a
"

# --- fzf default command: use fd if available, else find ---
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules'
else
    export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/.git/*" -not -path "*/node_modules/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='find . -type d -not -path "*/.git/*"'
fi

# --- Preview options ---
if command -v bat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:100 {}' --preview-window=right:55%"
else
    export FZF_CTRL_T_OPTS="--preview 'head -100 {}' --preview-window=right:55%"
fi

export FZF_ALT_C_OPTS="--preview 'eza --tree --icons --color=always -L 2 {} 2>/dev/null || ls -la {}' --preview-window=right:55%"

export FZF_CTRL_R_OPTS="
    --preview 'echo {}'
    --preview-window=down:3:hidden:wrap
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
    --color=header:italic
    --header 'Press CTRL-Y to copy command | CTRL-/ to toggle preview'
"

# --- Load fzf keybindings & completions ---
if [[ -f /usr/share/fzf/shell/key-bindings.bash ]]; then
    source /usr/share/fzf/shell/key-bindings.bash
elif [[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.bash
elif [[ -f ~/.fzf.bash ]]; then
    source ~/.fzf.bash
fi

if [[ -f /usr/share/fzf/shell/completion.bash ]]; then
    source /usr/share/fzf/shell/completion.bash
elif [[ -f /usr/share/doc/fzf/examples/completion.bash ]]; then
    source /usr/share/doc/fzf/examples/completion.bash
fi

# --- fzf Functions ---

# fkill: fuzzy kill a process
fkill() {
    local pid
    if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $UID | sed 1d | fzf -m --header='[kill] select process(es)' | awk '{print $2}')
    else
        pid=$(ps -ef | sed 1d | fzf -m --header='[kill] select process(es)' | awk '{print $2}')
    fi
    if [ -n "$pid" ]; then
        echo "$pid" | xargs kill -${1:-9}
        echo "✓ Killed: $pid"
    fi
}

# fcd: fuzzy cd with directory preview
fcd() {
    local dir
    dir=$(
        fd --type d --hidden --follow --exclude .git --exclude node_modules . "${1:-.}" 2>/dev/null \
        | fzf --header='[cd] select directory' \
              --preview 'eza --tree --icons --color=always -L 2 {} 2>/dev/null || ls -la {}'
    ) && cd "$dir"
}

# fh: fuzzy search command history and run
fh() {
    local cmd
    cmd=$(history | awk '{$1=""; print substr($0,2)}' | sort -u | fzf --tac --header='[history] select command to run')
    if [ -n "$cmd" ]; then
        echo "Running: $cmd"
        eval "$cmd"
    fi
}

# fenv: fuzzy search environment variables
fenv() {
    env | sort | fzf --header='[env] environment variables' --preview 'echo {}'
}

# fopen: fuzzy find and open a file with $EDITOR
fopen() {
    local file
    file=$(fzf --header='[open] select file' --preview 'bat --color=always --style=numbers {}' --preview-window=right:60%)
    [ -n "$file" ] && ${EDITOR:-nano} "$file"
}

# fport: fuzzy search and kill a port listener
fport() {
    local port
    port=$(ss -tlnp | fzf --header='[port] select port listener' | awk '{print $4}' | cut -d: -f2)
    echo "Selected port: $port"
}

# fbranch: fuzzy git branch switcher
fbranch() {
    local branch
    branch=$(git branch --all | grep -v HEAD | sed 's/remotes\/origin\///' | sort -u | fzf --header='[git] switch branch')
    [ -n "$branch" ] && git checkout "$(echo "$branch" | sed 's/^[ *]*//')"
}

# flog: fuzzy git log with preview
flog() {
    git log --oneline --color=always \
    | fzf --ansi --no-sort --reverse \
          --header='[git log] select commit' \
          --preview 'git show --color=always {1}' \
          --preview-window=right:60% \
          --bind 'enter:execute(git show --color=always {1} | bat --style=plain)'
}
