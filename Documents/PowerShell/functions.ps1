# functions.ps1 — managed by chezmoi (Windows). Dot-sourced from the profile.
# Port of helpers from functions.zsh (single-profile / ubuntu variant).

# --- General utilities ---
function mkcd {
  param([Parameter(Mandatory)][string]$Dir)
  New-Item -ItemType Directory -Force -Path $Dir | Out-Null
  Set-Location -LiteralPath $Dir
}
function backupfile {
  param([Parameter(Mandatory)][string]$File)
  Copy-Item -LiteralPath $File "$File.$(Get-Date -Format 'yyyyMMdd_HHmmss').bak"
}
Set-Alias bak backupfile
function serve {
  param([int]$Port = 8000)
  python -m http.server $Port
}
function jqpretty {
  if ($args.Count) { $args[0] | jq . } else { $input | jq . }
}
Set-Alias jqp jqpretty


# Color for the Claude prompt. Change this to tell Windows-native Claude apart
# from your WSL (ubuntu) Claude if you run both at once.
$script:_claudeColor = 'orange'

# --- Claude ---
# c / cc are functions so '/color' lands AFTER your args. The '!'-variants add
# --dangerously-skip-permissions (canonical daily form).
function c   { claude @args /color $script:_claudeColor }
function cc  { c --continue @args }
function c!  { c --dangerously-skip-permissions @args }
function cc! { cc --dangerously-skip-permissions @args }

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
