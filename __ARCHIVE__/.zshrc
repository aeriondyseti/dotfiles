# ~/.zshrc: executed by zsh(1) for interactive shells.


# ─────────────────────────────────────────
# History
# ─────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS APPEND_HISTORY


# ─────────────────────────────────────────
# Oh My Zsh
# ─────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(
  1password aliases brew catimg chezmoi colored-man-pages command-not-found
  cp dnote docker docker-compose dotenv extract fzf gh git git-commit
  git-extras gitignore kitty mise nmap ssh sudo uv
  zsh-autosuggestions zsh-syntax-highlighting alias-finder
)
source "$ZSH/oh-my-zsh.sh"


# ─────────────────────────────────────────
# Source config files
# ─────────────────────────────────────────
[ -f ~/.config/zsh/env.zsh ]       && source ~/.config/zsh/env.zsh
[ -f ~/.config/zsh/aliases.zsh ]   && source ~/.config/zsh/aliases.zsh
[ -f ~/.config/zsh/functions.zsh ] && source ~/.config/zsh/functions.zsh


# ─────────────────────────────────────────
# Completions and key-bindings
# ─────────────────────────────────────────
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ]   && source /usr/share/doc/fzf/examples/completion.zsh


# ─────────────────────────────────────────
# Final initializations
# ─────────────────────────────────────────
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
eval "$(zoxide init zsh)"
eval "$(oh-my-posh init zsh --config "$HOME/.config/oh-my-posh/config.toml")"

# Patch oh-my-posh's cached init to use our set_poshcontext instead of the stub.
# oh-my-posh re-sources its init file on every precmd, so we can't just override
# the function after eval — we have to patch the cached file itself.
_omp_init_file="$(oh-my-posh init zsh --config "$HOME/.config/oh-my-posh/config.toml" 2>/dev/null | grep -oP "source \\\$?'\K[^']+")"
if [[ -f "$_omp_init_file" ]] && grep -q 'function set_poshcontext' "$_omp_init_file"; then
    sed -i '/^function set_poshcontext/,/^}/c\function set_poshcontext() { source ~/.config/zsh/poshcontext.zsh; }' "$_omp_init_file"
fi
unset _omp_init_file


# ─────────────────────────────────────────
# Local overrides (not checked in)
# ─────────────────────────────────────────
[ -f ~/.config/zsh/local.zsh ] && source ~/.config/zsh/local.zsh
export PATH="$HOME/.local/bin:$PATH"

# ─────────────────────────────────────────
# zstyle settings
# ─────────────────────────────────────────
zstyle ':omz:plugins:alias-finder' autoload yes # disabled by default
zstyle ':omz:plugins:alias-finder' longer yes # disabled by default
zstyle ':omz:plugins:alias-finder' exact yes # disabled by default
zstyle ':omz:plugins:alias-finder' cheaper yes # disabled by default
