# ============================================================
# 01-env.sh — Environment variables & history settings
# ============================================================

# --- Editor ---
export EDITOR='nvim'
export VISUAL="$EDITOR"

# --- Locale ---
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# --- Better pager (use bat if available, else less) ---
if command -v bat &>/dev/null; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export PAGER='bat --style=plain'
else
    export PAGER='less -R'
fi
export LESS='-R --quit-if-one-screen --ignore-case --status-column --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --no-init --window=-4'

# --- Colors ---
export CLICOLOR=1
export COLORTERM=truecolor

# --- XDG Base Dirs ---
# Not set on purpose: the defaults (~/.config, ~/.local/share, ~/.cache) are
# what apps started from sway use too, so terminal and GUI apps share one
# data dir. (A shell-only XDG_DATA_HOME split nvim, zoxide etc. into two.)

# --- History (best settings, zero perf cost) ---
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups    # ignore dupes & lines starting with space
export HISTTIMEFORMAT="%F %T  "            # timestamps: 2026-11-07 11:00:00
export HISTIGNORE='ls:ll:la:lt:cd:pwd:exit:clear:history:q:bg:fg'
shopt -s histappend                        # append to history, don't overwrite
shopt -s cmdhist                           # save multi-line cmds as one entry

# Save history after every command (not just on exit)
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a"

# --- Shell options (all free, no perf cost) ---
shopt -s autocd           # type a dir name to cd into it
shopt -s cdspell          # fix minor typos in cd path
shopt -s dirspell         # fix typos in directory tab completion
shopt -s globstar         # ** matches recursively across dirs
shopt -s checkwinsize     # update LINES/COLUMNS after each cmd
shopt -s nocaseglob       # case-insensitive globbing

# --- Better cd with CDPATH (search common dirs) ---
export CDPATH=".:$HOME:$HOME/projects:$HOME/work"
