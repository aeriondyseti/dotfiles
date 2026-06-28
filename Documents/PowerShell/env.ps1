# env.ps1 — managed by chezmoi (Windows). Environment variables.
# Dot-sourced first by the profile. Windows-relevant subset of env.zsh
# (XDG path redirects and Linux-only vars are intentionally omitted).

# Editor — prefer VS Code, fall back to notepad. Used by EDITOR/VISUAL and editsh*.
$_editor    = if (Get-Command code -ErrorAction SilentlyContinue) { 'code' } else { 'notepad' }
$env:EDITOR = $_editor
$env:VISUAL = $_editor

# bat
$env:BAT_THEME = 'ansi'

# fzf
$env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --inline-info'

# Python
$env:PYTHONDONTWRITEBYTECODE = '1'
$env:PYTHONUNBUFFERED         = '1'

# Hugging Face — faster downloads
$env:HF_HUB_ENABLE_HF_TRANSFER = '1'

# Gemini CLI
$env:GEMINI_TOOL_PRESET   = 'text'
$env:GEMINI_ENABLED_TOOLS = 'image-gen,image-edit,image-analyze'
