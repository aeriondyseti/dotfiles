# env vars.
export EDITOR='code'
export HOMEBREW_NO_ENV_HINTS=1
export ENABLE_TOOL_SEARCH=true

alias omp='oh-my-posh'


# update cost tracker cuz it's wrong again:
alias upcost='/Users/kevinwhiteside/Development/Scripts/claude-tracker/update_cost.sh'

# use exa instead of ls
alias ls='eza -a --color=always --group-directories-first --icons --grid'
alias ll='eza -la --color=always --group-directories-first --icons --octal-permissions --grid'
alias llm='eza -lbGd --header --git --sort=modified --color=always --group-directories-first --icons --grid'
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons'
alias lt='eza --tree --level=2 --color=always --group-directories-first --icons'

# convenience aliases
alias home='cd ~'
alias gitlog='git log --all --pretty=format:"%h %s" --graph'
alias cls='clear'
alias tf='terraform'
alias lzd='lazydocker'
alias k='kubectl'
alias kc='kubectl config current-context'
alias plumbK='plumber write kafka --address localhost:9092'
alias sp='spotify_player'

# resource zshrc
alias resetz='source ~/.zshrc'

# create directory and cd into it immediately
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# cd into ~/Development/<dir> with tab completion
dev() {
  cd "$HOME/Development/$1"
}
_dev () {
  ((CURRENT == 2)) &&
  _files -/ -W "$HOME/Development"
}
compdef _dev dev

# Delete all local branches except env branches and master
gbclean() {
    git branch | grep -v "master" | grep -v "env/.*" | xargs git branch -D
}

# claude code aliases

alias cprofiles='npx -y @aeriondyseti/claude-profiles'

alias c='claude-work'
alias cc='claude-work --continue'
alias c!='claude-work --dangerously-skip-permissions'
alias cc!='claude-work --continue --dangerously-skip-permissions'

alias claude-work='CLAUDE_CONFIG_DIR=~/.claude-work \claude'
alias claude-personal='CLAUDE_CONFIG_DIR=~/.claude-personal \claude'

alias cwork='claude-work  --dangerously-skip-permissions "/color blue"'
alias cpers='claude-personal  --dangerously-skip-permissions "/color orange"'
alias cpersonal='claude-personal  --dangerously-skip-permissions "/color orange"'
alias ccwork='claude-work --continue --dangerously-skip-permissions "/color blue"'
alias ccpers='claude-personal --continue --dangerously-skip-permissions "/color orange"'
alias ccpersonal='claude-personal --continue --dangerously-skip-permissions "/color orange"'

# ask claude a single question without entering the TUI
ask-claude() {
  if [ -z "$*" ]; then
    echo "Usage: ask-claude '<question>'" >&2
    return 1
  fi
      claude -p "$*" \
      --allowedTools "Read,Grep,Glob" \
      --disallowedTools "Write,Edit,Bash"
}

alias ask='ask-claude'


# function gcommit() {
#     # 1. Check for staged changes
#     if git diff --cached --quiet; then
#         echo "Nothing staged to commit. Run 'git add' first."
#         return 1
#     fi

#     echo "🤖 Asking Gemini to write a commit message..."

#     # 2. Generate message via pipe
#     MSG=$(git diff --cached | gemini --prompt "Write a git commit message for this diff. Use Conventional Commits. First line under 72 chars. Output ONLY the raw message.")

#     # 3. Confirm and Commit
#     echo "\n------------------------------------------------"
#     echo "$MSG"
#     echo "------------------------------------------------\n"
    
#     read -q "CONFIRM?Do you want to commit with this message? (y/n) "
#     echo ""
    
#     if [[ "$CONFIRM" == "y" ]]; then
#         git commit -m "$MSG"
#     else
#         echo "Commit cancelled."
#     fi
# }

function gcommit() {
    if git diff --cached --quiet; then
        echo "Nothing staged to commit. Run 'git add' first."
        return 1
    fi

    # Call the shell script
    MSG=$(~/Development/scripts/gcommit.sh)

    if [[ $? -ne 0 ]]; then
        return 1
    fi

    echo "\n------------------------------------------------"
    echo "$MSG"
    echo "------------------------------------------------\n"

    read -q "CONFIRM?Do you want to commit with this message? (y/n) "
    echo ""

    if [[ "$CONFIRM" == "y" ]]; then
        git commit -m "$MSG"
    else
        echo "Commit cancelled."
    fi
}
