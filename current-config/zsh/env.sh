# Common env vars
export DOCKER_DEFAULT_PLATFORM=linux/arm64
export API_TIMEOUT_MS=600000

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Android SDK (make emulator easier to get to)
export ANDROID_HOME=~/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"

# Brew Tab completions
  if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
  fi
. "$HOME/.local/bin/env"

# bun completions
[ -s "/Users/kevinwhiteside/.bun/_bun" ] && source "/Users/kevinwhiteside/.bun/_bun"


# Aider Settings Key
export AIDER_EDITOR="code --wait"