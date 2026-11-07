# ============================================================
# 06-functions.sh — Utility shell functions
# ============================================================

# --- mkcd: mkdir + cd in one step ---
mkcd() {
    [ -z "$1" ] && { echo "Usage: mkcd <dir>"; return 1; }
    mkdir -p "$1" && cd "$1" && echo "✓ Created and entered: $(pwd)"
}

# --- bak: quick timestamped backup of a file ---
bak() {
    [ -z "$1" ] && { echo "Usage: bak <file>"; return 1; }
    local dest="${1}.bak.$(date +%Y%m%d_%H%M%S)"
    cp -v "$1" "$dest"
}

# --- extract: universal archive extractor ---
extract() {
    if [ -z "$1" ]; then
        echo "Usage: extract <archive>"
        echo "Supports: tar.gz, tar.bz2, tar.xz, zip, rar, 7z, gz, bz2, xz, Z, deb, rpm"
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo "Error: '$1' is not a file."
        return 1
    fi
    case "$1" in
        *.tar.bz2)   tar xjf "$1"     ;;
        *.tar.gz)    tar xzf "$1"     ;;
        *.tar.xz)    tar xJf "$1"     ;;
        *.tar.zst)   tar --zstd -xf "$1" ;;
        *.tar)       tar xf "$1"      ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.gz)        gunzip "$1"      ;;
        *.xz)        unxz "$1"        ;;
        *.zip)       unzip "$1"       ;;
        *.Z)         uncompress "$1"  ;;
        *.7z)        7z x "$1"        ;;
        *.rar)       unrar x "$1"     ;;
        *.deb)       ar x "$1"        ;;
        *.rpm)       rpm2cpio "$1" | cpio -idmv ;;
        *)           echo "Don't know how to extract '$1'" ; return 1 ;;
    esac
    echo "✓ Extracted: $1"
}

# --- compress: create a tar.gz archive ---
compress() {
    [ -z "$1" ] && { echo "Usage: compress <dir/file> [output.tar.gz]"; return 1; }
    local output="${2:-$(basename "$1").tar.gz}"
    tar czf "$output" "$1" && echo "✓ Created: $output"
}

# --- up: go up N directories ---
up() {
    local n="${1:-1}"
    local path=""
    for ((i=0; i<n; i++)); do path="../$path"; done
    cd "$path" || return
}

# --- repeat: run a command N times ---
repeat() {
    local n="$1"; shift
    for ((i=0; i<n; i++)); do "$@"; done
}

# --- calc: quick calculator ---
calc() {
    echo "${*}" | bc -l
}

# --- size: show size of a file/dir nicely ---
size() {
    du -sh "${1:-.}" | cut -f1
}

# --- biggest: find N biggest files in a dir ---
biggest() {
    du -ah "${2:-.}" | sort -rh | head -n "${1:-10}"
}

# --- serve: quick HTTP server in current dir ---
serve() {
    local port="${1:-8000}"
    echo "▶ Serving $(pwd) at http://localhost:$port"
    python3 -m http.server "$port"
}

# --- myip: show public + local IPs ---
myip() {
    echo "Public IP : $(curl -s --max-time 3 ifconfig.me || echo 'unavailable')"
    echo "Local  IP : $(ip route get 1 2>/dev/null | awk '{print $NF;exit}' || hostname -I | awk '{print $1}')"
}

# --- note: quick notes to ~/notes.md ---
note() {
    local notefile="$HOME/notes.md"
    if [ -z "$1" ]; then
        ${EDITOR:-nano} "$notefile"
    else
        echo "- [$(date '+%F %T')] $*" >> "$notefile"
        echo "✓ Note saved to $notefile"
    fi
}

# --- hgrep: search command history ---
hgrep() {
    history | grep --color=always -i "$1" | tail -50
}

# --- envgrep: search env variables ---
envgrep() {
    env | grep --color=always -i "$1" | sort
}

# --- port: check what's using a port ---
port() {
    [ -z "$1" ] && { echo "Usage: port <number>"; return 1; }
    ss -tlnp | grep ":$1 " || echo "Nothing listening on port $1"
}

# --- git: quick summary of a repo ---
grepo() {
    echo "── Branch:  $(git branch --show-current 2>/dev/null)"
    echo "── Remote:  $(git remote get-url origin 2>/dev/null)"
    echo "── Commits: $(git rev-list --count HEAD 2>/dev/null)"
    echo "── Status:"
    git status -sb 2>/dev/null
}

# --- reload: source bashrc with confirmation ---
reload() {
    source ~/.bashrc
    echo "✓ ~/.bashrc reloaded"
}

# --- Lazy-loader template for slow tools ---
# Uncomment and adapt if you use nvm/conda/rvm:
#
# nvm() {
#     unset -f nvm node npm npx
#     export NVM_DIR="$HOME/.nvm"
#     [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
#     nvm "$@"
# }
# node() { nvm; node "$@"; }
# npm()  { nvm; npm "$@";  }
# npx()  { nvm; npx "$@";  }
