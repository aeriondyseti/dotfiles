# Functions — ported from dotfiles (zsh/functions.zsh.tmpl, ubuntu profile).
# Sourced after Omarchy's defaults. Omarchy aliases that clash with these
# names are removed first (an alias would break the function definition).
unalias c cc chelp mkcd serve fa dev 2>/dev/null

# ─────────────────────────────────────────
# General
# ─────────────────────────────────────────

mkcd() {
    : "Create a directory (with parents) and cd into it."
    if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
        echo "Usage: mkcd <directory>"
        echo "  Creates a directory (including parents) and cd into it."
        return 0
    fi
    mkdir -p "$1" && builtin cd "$1"
}

backupfile() {
    : "Make a timestamped .bak copy of a file (file.YYYYMMDD_HHMMSS.bak)."
    if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
        echo "Usage: backupfile <file>"
        echo "  Creates a timestamped backup copy of a file."
        echo "  Example: backupfile config.yaml → config.yaml.20240304_142531.bak"
        return 0
    fi
    command cp "$1" "$1.$(date +%Y%m%d_%H%M%S).bak"
}
alias bak='backupfile'

serve() {
    : "Serve the current directory over HTTP (default port 8000)."
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Usage: serve [port]"
        echo "  Serves the current directory over HTTP."
        echo "  Defaults to port 8000 if none specified."
        return 0
    fi
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

jqpretty() {
    : "Pretty-print JSON from argument or stdin."
    if [ -n "$1" ]; then
        echo "$1" | jq .
    else
        jq .
    fi
}
alias jqp='jqpretty'

shedit() {
    : "Edit a shell config file: rc, aliases, funcs, env, path, api, local."
    case "$1" in
        rc)      $EDITOR ~/.bashrc ;;
        aliases) $EDITOR ~/.config/bash/aliases.bash ;;
        funcs)   $EDITOR ~/.config/bash/functions.bash ;;
        env)     $EDITOR ~/.config/bash/env.bash ;;
        path)    $EDITOR ~/.config/bash/path.bash ;;
        api)     $EDITOR ~/.config/bash/api-keys.bash ;;
        local)   $EDITOR ~/.config/bash/local.bash ;;
        *)       echo "Usage: shedit {rc|aliases|funcs|env|path|api|local}"; return 1 ;;
    esac
}

gbclean() {
    : "Delete all local branches except master and env/* branches."
    git branch | grep -v "master" | grep -v "env/.*" | xargs git branch -D
}

# ─────────────────────────────────────────
# Project navigation
# ─────────────────────────────────────────

dev() {
    : "cd into ~/development/<dir> (tab-completes)."
    builtin cd "$HOME/development/$1"
}
_dev_complete() {
    local base="$HOME/development"
    [[ -d "$base" ]] || return
    COMPREPLY=( $(cd "$base" && compgen -d -- "${COMP_WORDS[COMP_CWORD]}") )
}
complete -o nospace -F _dev_complete dev

# ─────────────────────────────────────────
# Claude helpers
# ─────────────────────────────────────────
# `c`/`cc` are functions so the `/color` slash command lands AFTER user args.
# The !-variants add --dangerously-skip-permissions. Omarchy's `cx` still
# launches Claude in auto permission mode.

ask-claude() {
    : "Ask claude a single question without entering the TUI (read-only tools)."
    if [ -z "$*" ]; then
        echo "Usage: ask-claude '<question>'" >&2
        return 1
    fi
    command claude -p "$*" \
        --allowedTools "Read,Grep,Glob" \
        --disallowedTools "Write,Edit,Bash"
}
alias ask='ask-claude'

c() {
    : "Spawn claude (orange prompt)."
    command claude "$@" /color orange
}
cc() {
    : "Continue the last claude session."
    c --continue "$@"
}
chelp() {
    : "Spawn claude with the helper system prompt loaded."
    command claude --system-prompt-file <(helper-prompt) "$@" /color orange
}

alias 'c!'='c --dangerously-skip-permissions'
alias 'cc!'='cc --dangerously-skip-permissions'
alias 'chelp!'='chelp --dangerously-skip-permissions'

# ─────────────────────────────────────────
# Fuzzy stuff (fzf)
# ─────────────────────────────────────────

fkillProc() {
    : "Fuzzy-pick a process and kill it. Use --force/-f for SIGKILL."
    local pid sig=15
    if [[ "$1" == "--force" || "$1" == "-f" ]]; then
        sig=9
        shift
    fi
    pid=$(ps aux | fzf --header-lines=1 --preview 'echo {}' | awk '{print $2}')
    [ -n "$pid" ] && kill -"$sig" "$pid" && echo "Killed $pid (SIG$([ $sig -eq 9 ] && echo KILL || echo TERM))"
}
alias fkill='fkillProc'

fkillport() {
    : "Fuzzy-pick a listening port's owner and kill it. --root for sudo, --force for SIGKILL."
    local selection pid sudo_cmd="" sig=15
    for arg in "$@"; do
        case "$arg" in
            --root|-r)  sudo_cmd="sudo" ;;
            --force|-f) sig=9 ;;
            *) echo "Usage: fkillport [--root|-r] [--force|-f]"; return 1 ;;
        esac
    done
    if [[ -n "$sudo_cmd" ]] && ! sudo -v; then
        echo "Error: sudo authentication failed."
        return 1
    fi
    selection=$( $sudo_cmd ss -tulnp | fzf --header-lines=1 --prompt="Kill Port> " --preview 'echo {}' )
    if [[ -n "$selection" ]]; then
        pid=$(echo "$selection" | grep -oP 'pid=\K[0-9]+' | head -1)
        if [[ -n "$pid" ]]; then
            $sudo_cmd kill -"$sig" "$pid" && echo "Sent SIG$([ $sig -eq 9 ] && echo KILL || echo TERM) to PID $pid"
        else
            echo "Error: No PID found in selection."
            [[ -z "$sudo_cmd" ]] && echo "(Try running with --root if it's a system process)"
        fi
    fi
}
alias fkp='fkillport'

# ─────────────────────────────────────────
# fa — fuzzy-find aliases and functions (Alt+A inserts the pick)
# ─────────────────────────────────────────

fa() {
    : "Fuzzy-find aliases and functions, with descriptions and previews."
    local defs sel fn doc
    defs=$(mktemp)
    { alias -p; declare -f; } > "$defs"
    sel=$(
        {
            alias -p | sed -E 's/^alias ([^=]+)=.*/alias: \1/'
            for fn in $(compgen -A function | grep -v '^_'); do
                doc=$(declare -f "$fn" | grep -m1 -oE ':[[:space:]]+"[^"]+"' | sed -E 's/^:[[:space:]]+"//; s/"$//')
                if [[ -n "$doc" ]]; then
                    printf 'func:  %s  —  %s\n' "$fn" "$doc"
                else
                    printf 'func:  %s\n' "$fn"
                fi
            done
        } | sort -u | fzf --preview "fa-preview '$defs' {2}" --preview-window=down:15
    )
    rm -f "$defs"
    [[ -z "$sel" ]] && return
    awk '{print $2}' <<< "$sel"
}

_fa_insert() {
    local pick
    pick=$(fa)
    READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}${pick}${READLINE_LINE:READLINE_POINT}"
    READLINE_POINT=$(( READLINE_POINT + ${#pick} ))
}
[[ $- == *i* ]] && bind -x '"\ea": _fa_insert'
