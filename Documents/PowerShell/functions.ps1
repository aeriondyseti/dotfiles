# functions.ps1 — managed by chezmoi (Windows). Dot-sourced from the profile.
# Port of the AI-tool helpers from functions.zsh (single-profile / ubuntu variant).

# Color for the Claude prompt. Change this to tell Windows-native Claude apart
# from your WSL (ubuntu) Claude if you run both at once.
$script:_claudeColor = 'orange'

# --- Claude ---
# c / cc are functions so '/color' lands AFTER your args. The '!'-variants add
# --dangerously-skip-permissions (canonical daily form).
function c   { claude @args /color $script:_claudeColor }
function cc  { c --continue @args }
function 'c!'  { c --dangerously-skip-permissions @args }
function 'cc!' { cc --dangerously-skip-permissions @args }

# ask: one-shot question, read-only tools, no TUI.
function ask-claude {
  if (-not $args) { Write-Error "Usage: ask '<question>'"; return }
  claude -p "$args" --allowedTools "Read,Grep,Glob" --disallowedTools "Write,Edit,Bash"
}
Set-Alias ask ask-claude

# claude-profiles launcher
function cprofiles { npx -y '@aeriondyseti/claude-profiles' @args }

# --- Gemini ---
function gm  { gemini @args }
function gmc { gemini --continue @args }
