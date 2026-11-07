# ============================================================
# 05-starship.sh — Starship prompt
# ============================================================

# Skip if starship is not installed
command -v starship &>/dev/null || return 0

# Initialize starship prompt
# Config lives at: ~/.config/starship.toml
# Docs: https://starship.rs/config/
eval "$(starship init bash)"
