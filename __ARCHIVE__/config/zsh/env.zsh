# Environment - Template from aeriondyseti/dotfiles

export EDITOR=code
export BROWSER=xdg-open
export MANROFFOPT="-c"


# ─────────────────────────────────────────
# bat
# ─────────────────────────────────────────
export BAT_THEME="Dracula"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ─────────────────────────────────────────
# FZF
# ─────────────────────────────────────────
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"

# ─────────────────────────────────────────
# Python
# ─────────────────────────────────────────
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

# ─────────────────────────────────────────
# huggingface
# ─────────────────────────────────────────
export HF_HUB_ENABLE_HF_TRANSFER=1


# ─────────────────────────────────────────
# PATH
# ─────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.spicetify:$PATH" # spicetify
export PATH="$HOME/.bun/bin:$PATH" # bun
export PATH="$HOME/.lmstudio/bin:$PATH" # lm studio
