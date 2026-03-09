{ config, lib, ... }:

let
  cfg = config.dotfiles;
in
{
  options.dotfiles.shellConfig = {
    aliases = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Shell aliases as raw text, shared across all shell types.";
    };

    envVars = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Environment variables shared across all shell types.";
    };

    functions = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Shell functions as a raw string (bash/zsh compatible).";
    };
  };

  config.dotfiles.shellConfig = {
    aliases = ''
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
      alias localip='hostname -I | xargs -n1 | head -1'

      # Misc
      alias path='echo $PATH | tr ":" "\n"'
      alias now='date +"%Y-%m-%d %H:%M:%S"'
      alias shrc='$EDITOR ~/.zshrc'
      alias reload='source ~/.zshrc'

      # Bat
      alias cat='bat --paging=never'
      alias catp='bat'

      # Eza
      alias ls='eza -a --color=always --group-directories-first --icons --grid'
      alias ll='eza -la --color=always --group-directories-first --icons --octal-permissions --grid'
      alias llm='eza -lbGd --header --git --sort=modified --color=always --group-directories-first --icons --grid'
      alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons'
      alias lt='eza --tree --level=2 --color=always --group-directories-first --icons'

      # fd
      alias f='fd'
      alias ff='fd --type f'
      alias fh='fd --hidden'

      # Ripgrep
      alias rgi='rg --no-ignore'

      # Zoxide
      alias cd='z'
      alias cdi='zi'

      # Git
      alias ga='git add'
      alias gcm='git commit'
      alias gp='git push'
      alias gpl='git pull'
      alias gs='git status'
      alias gd='git diff'
      alias gl='git log --oneline -n 20'
      alias wip='git add . && git commit -m "WIP" --no-verify && git push'
      alias oops='git stash push -u -m "oops-$(date +%Y%m%d-%H%M)" && git reset --hard HEAD'
      alias nope='git checkout - && git branch -D @{-1}'
    '';

    envVars = {
      EDITOR = "code";
      BAT_THEME = "Dracula";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      DELTA_PAGER = "less -R";
      FZF_DEFAULT_COMMAND = "fd --type f --hidden --exclude .git";
    };

    functions = ''
      # Quick directory creation and cd
      mkcd() { mkdir -p "$1" && cd "$1"; }

      # Find process by name
      findprocess() { ps aux | grep -v grep | grep -i "$1"; }

      # Backup file with timestamp
      bak() { cp "$1" "$1.$(date +%Y%m%d_%H%M%S).bak"; }

      # Create temp directory and cd into it
      tmpcd() { local dir; dir=$(mktemp -d); echo "Created $dir"; cd "$dir"; }

      # Quick scratch note
      scratch() {
        local file
        file=$(mktemp --suffix=.md)
        if [ -n "$1" ]; then
          echo "$*" > "$file"
          echo "Wrote to: $file"
        else
          $EDITOR "$file"
        fi
        echo "$file"
      }

      # Cat the last scratch file
      lscratch() {
        local last
        last=$(ls -t /tmp/tmp.*.md 2>/dev/null | head -1)
        if [ -n "$last" ]; then
          cat "$last"
          echo -e "\n---\n$last"
        else
          echo "No scratch files found"
        fi
      }

      # Check what's on a port
      port() { ss -tulnp | grep ":$1"; }

      # Kill process on a port
      killport() {
        local pid
        pid=$(ss -tulnp | grep ":$1" | awk '{print $7}' | grep -oP 'pid=\K[0-9]+' | head -1)
        if [ -n "$pid" ]; then
          kill -9 "$pid" && echo "Killed PID $pid on port $1"
        else
          echo "No process found on port $1"
        fi
      }

      # Quick serve current directory
      serve() { python3 -m http.server "''${1:-8000}"; }

      # Man pages with bat
      bman() { man "$1" | bat --language=man --plain; }

      # jq pretty-print
      jqp() {
        if [ -n "$1" ]; then
          echo "$1" | jq .
        else
          jq .
        fi
      }

      # Curl + jq
      jcurl() { curl -s "$@" | jq .; }

      # Fuzzy cd into subdirectories
      fcd() {
        local dir
        dir=$(fd --type d --hidden --exclude .git 2>/dev/null | fzf --preview 'eza --tree --level=1 {} 2>/dev/null || ls -la {}') && cd "$dir"
      }

      # Fuzzy open file in editor
      fe() {
        local file
        file=$(fzf --preview 'bat --color=always --line-range=:500 {} 2>/dev/null || head -100 {}') && $EDITOR "$file"
      }

      # Fuzzy git branch checkout
      fbr() {
        local branch
        branch=$(git branch --all | grep -v HEAD | sed 's/^..//' | fzf --preview 'git log --oneline -20 {}') || return
        branch=$(echo "$branch" | sed 's#remotes/origin/##')
        git checkout "$branch"
      }

      # Fuzzy kill process
      fkill() {
        local pid
        pid=$(ps aux | fzf --header-lines=1 --preview 'echo {}' | awk '{print $2}')
        [ -n "$pid" ] && kill -9 "$pid" && echo "Killed $pid"
      }

      # Fuzzy search git log
      flog() {
        git log --oneline --color=always | fzf --ansi --preview 'git show --color=always {1}' | awk '{print $1}' | xargs -r git show
      }

      # Git: reset branch to origin
      gitclean() {
        local branch="''${1:-$(git branch --show-current)}"
        local stash_msg="WIP: $(date +%Y-%m-%d_%H:%M:%S) on $branch"
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
          echo "Not in a git repository"; return 1
        fi
        if ! git diff --quiet || ! git diff --cached --quiet; then
          echo "Stashing changes: $stash_msg"
          git stash push -m "$stash_msg"
        fi
        if git rev-parse --verify "origin/$branch" &>/dev/null; then
          echo "Resetting $branch to origin/$branch"
          git fetch origin "$branch"
          git reset --hard "origin/$branch"
        else
          echo "No upstream branch origin/$branch found"; return 1
        fi
      }

      # Commit with conventional commit prefix
      gcom() { local type="$1"; shift; git commit -m "$type: $*"; }

      # Quick amend without editing message
      gamend() { git add -A && git commit --amend --no-edit; }

      # Delete local branches that have been merged
      gcleanup() { git branch --merged | grep -v '\*\|main\|master' | xargs -r git branch -d; }

      # Lightweight branch for trying something crazy
      experiment() {
        local name="''${1:-$(date +%H%M)}"
        git checkout -b "experiment/$name" && echo "Go wild. Abandon with: nope"
      }

      # Compare two repos side-by-side
      diffproj() { diff -rq ~/dev/"$1" ~/dev/"$2" --exclude=node_modules --exclude=.git --exclude=__pycache__ | head -30; }
    '';
  };

  # Ensure the chosen shell is registered in /etc/shells and set as the default login shell.
  # The /etc/shells entry requires sudo (prompted once); chsh does not.
  config.home.activation.setDefaultShell = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _shell="$HOME/.nix-profile/bin/${cfg.shell}"
    if ! grep -qxF "$_shell" /etc/shells 2>/dev/null; then
      echo "Registering $_shell in /etc/shells (requires sudo)..."
      $DRY_RUN_CMD /usr/bin/sudo /bin/sh -c "echo '$_shell' >> /etc/shells"
    fi
    _current=$(grep "^$USER:" /etc/passwd | cut -d: -f7)
    if [ "$_current" != "$_shell" ]; then
      echo "Setting default shell to $_shell (requires sudo)..."
      $DRY_RUN_CMD /usr/bin/sudo /usr/sbin/usermod -s "$_shell" "$USER"
    fi
  '';
}
