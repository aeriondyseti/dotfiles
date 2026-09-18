# PATH — ported from dotfiles (zsh/path.zsh.tmpl). Idempotent.
_prepend_path() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

_prepend_path "$HOME/.local/bin"
_prepend_path "${XDG_DATA_HOME:-$HOME/.local/share}/cargo/bin"
_prepend_path "${XDG_DATA_HOME:-$HOME/.local/share}/bun/bin"
[ -d "$HOME/.lmstudio/bin" ] && _prepend_path "$HOME/.lmstudio/bin"

unset -f _prepend_path
