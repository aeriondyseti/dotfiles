# Aliases — ported from dotfiles (zsh/aliases.zsh.tmpl, ubuntu profile).
# Sourced after Omarchy's defaults, so these win on conflicts.
# Kept Omarchy's: t (tmux), ff (fzf picker), cd (zoxide via zd).

# General
alias cls='clear'
alias path='echo $PATH | tr ":" "\n"'
alias now='date +"%Y-%m-%d %H:%M:%S"'

# Safety nets
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias rmrf='rm -rf'
alias mvf='mv -f'
alias cpf='cp -f'

# Networking
alias myip='curl -s ifconfig.me'
alias ports='ss -tulnp'
alias localip='hostname -I | awk "{print \$1}"'

# Git
alias gitlog='git log --all --pretty=format:"%h %s" --graph'

# Bat (cat replacement)
alias cat='bat --paging=never'
alias catp='bat'

# btop
alias top='btop'

# Eza (ls replacement) — overrides Omarchy's ls/lt
alias ls='eza -a --color=always --group-directories-first --icons'
alias ll='eza -la --color=always --group-directories-first --icons --octal-permissions'
alias llm='eza -lbGd --header --git --sort=modified --color=always --group-directories-first --icons'
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons'
alias lt='eza --tree --level=2 --color=always --group-directories-first --icons'

# fd (find replacement)
alias f='fd'
alias fh='fd --hidden'

# Ripgrep (grep replacement)
alias rg='command rg --smart-case'
alias rgi='command rg --no-ignore'

# zoxide interactive picker (Omarchy already maps cd -> zoxide)
alias cdi='zi'

# Shell quick edits
alias editshrc='$EDITOR ~/.bashrc'
alias editshaliases='$EDITOR ~/.config/bash/aliases.bash'
alias editshfuncs='$EDITOR ~/.config/bash/functions.bash'
alias editshenv='$EDITOR ~/.config/bash/env.bash'
alias shreload='source ~/.bashrc'

# Bun
alias b='bun'
alias br='bun run'
alias bx='bunx'
alias bi='bun install'
alias ba='bun add'
alias bad='bun add -d'

# Docker
alias d='docker'
alias dps='docker ps'
alias dls='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}"'
alias dlsa='docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}"'
alias di='docker images'
alias dv='docker volume ls'
alias dn='docker network ls'

# Docker Compose
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dcr='docker compose restart'
alias dcb='docker compose build'
alias dce='docker compose exec'

# Gemini
alias gm='gemini'
alias gmc='gemini --continue'

# lazydocker / lazygit
alias lzd='lazydocker'
alias lg='lazygit'

# UV
alias uvr='uv run'
alias uvs='uv sync'
alias uva='uv add'
alias uvad='uv add --dev'
alias uvp='uv pip'

# systemd
alias sc='systemctl'
alias ssc='sudo systemctl'
