# ============================================================
# 04-zoxide.sh — zoxide smart directory navigation
# ============================================================

# Skip if zoxide is not installed
command -v zoxide &>/dev/null || return 0

# Initialize zoxide (replaces cd with smart frecency-based jumping)
# z foo     → jump to most used dir matching "foo"
# zi        → interactive pick with fzf
# z -       → jump to previous dir
eval "$(zoxide init bash --cmd z)"

# Also keep 'cd' working normally (zoxide adds 'z' and 'zi')
# Optional: uncomment below to also replace 'cd' itself
# eval "$(zoxide init bash --cmd cd)"

# Convenience wrapper: 'zi' is already added by zoxide (interactive fzf picker)
# Extra alias for muscle memory
alias j='z'      # 'j' for jump — shorter to type
alias ji='zi'    # 'ji' for jump interactive
