# Aliases - Generated from aeriondyseti/dotfiles
# Platform: linux-amd64

# General
alias sc='systemctl'
alias ssc='sudo systemctl'
alias cls='clear'

# Safety nets
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Networking
alias ports='ss -tulnp'
alias myip='curl -s ifconfig.me'
alias localip='hostname -I | awk "{print \$1}"'

# Misc
alias path='echo $PATH | tr ":" "\n"'
alias now='date +"%Y-%m-%d %H:%M:%S"'

# Bat (cat replacement)
alias cat='bat --paging=never'
alias catp='bat'

# btop
alias top='btop'

# Bun
alias b='bun'
alias br='bun run'
alias bx='bunx'
alias bi='bun install'
alias ba='bun add'
alias bad='bun add -d'

# Claude
alias c='claude'
alias cc='claude --continue'
alias 'c!'='claude --dangerously-skip-permissions'
alias 'cc!'='claude --continue --dangerously-skip-permissions'

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

# Eza (ls replacement)
alias ls='eza -a --color=always --group-directories-first --icons --grid'
alias ll='eza -la --color=always --group-directories-first --icons --octal-permissions --grid'
alias llm='eza -lbGd --header --git --sort=modified --color=always --group-directories-first --icons --grid'
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons'
alias lt='eza --tree --level=2 --color=always --group-directories-first --icons'

# fd (find replacement)
alias f='fd'
alias ff='fd --type f'
alias fh='fd --hidden'

# gemini
alias gm='gemini'
alias gmc='gemini --continue'

# lazydocker
alias lzd='lazydocker'

# lazygit
alias lg='lazygit'

# Nala (apt replacement)
alias apt='nala'

# Ripgrep (grep replacement)
alias rg='/usr/bin/rg --smart-case'
alias rgi='/usr/bin/rg --no-ignore'

# UV
alias uvr='uv run'
alias uvs='uv sync'
alias uva='uv add'
alias uvad='uv add --dev'
alias uvp='uv pip'

# Zoxide (after init, 'z' is available)
alias cd='z'
alias cdi='zi'

# Shell quick edits
alias editshrc='$EDITOR ~/.bashrc'
alias editshaliases='$EDITOR ~/.config/bash/aliases.bash'
alias editshfuncs='$EDITOR ~/.config/bash/functions.bash'
alias editshenv='$EDITOR ~/.config/bash/env.bash'
alias shreload='source ~/.bashrc'
