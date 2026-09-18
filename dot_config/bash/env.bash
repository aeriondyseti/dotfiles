# Environment — ported from dotfiles (zsh/env.zsh.tmpl, ubuntu profile)
# Omarchy already sets BAT_THEME, MANPAGER, MANROFFOPT and BROWSER.

# Editors
export EDITOR='micro'
export VISUAL='code'
export SUDO_EDITOR="$EDITOR"

# Pagers
export PAGER='less'
export LESS='-R -F -X'
export SYSTEMD_LESS="$LESS"

# FZF
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'

# Python
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

# Hugging Face
export HF_HUB_ENABLE_HF_TRANSFER=1

# Gemini CLI defaults
export GEMINI_TOOL_PRESET=text
export GEMINI_ENABLED_TOOLS=image-gen,image-edit,image-analyze

# XDG base dirs (defaults made explicit for the redirects below)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# XDG redirects for tools that hard-code $HOME paths
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"
export HF_HOME="$XDG_CACHE_HOME/huggingface"
export OLLAMA_MODELS="$XDG_DATA_HOME/ollama/models"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export __GL_SHADER_DISK_CACHE_PATH="$XDG_CACHE_HOME/nv"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
