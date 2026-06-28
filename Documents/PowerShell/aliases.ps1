# aliases.ps1 — managed by chezmoi (Windows). PowerShell 7 port of aliases.zsh.
# Dot-sourced from Microsoft.PowerShell_profile.ps1.

# --- free up built-in aliases so our functions can take their names ---
'ls','cat','cp','mv','rm' | ForEach-Object {
  if (Test-Path "Alias:$_") { Remove-Item "Alias:$_" -Force }
}

$script:_editor = if (Get-Command code -ErrorAction SilentlyContinue) { 'code' } else { 'notepad' }

# --- General ('cls' is already built-in Clear-Host) ---
function path { $env:PATH -split ';' }
function now  { Get-Date -Format 'yyyy-MM-dd HH:mm:ss' }

# --- Safety nets / force variants ---
function rmrf { Remove-Item -Recurse -Force @args }
function mvf  { Move-Item   -Force @args }
function cpf  { Copy-Item   -Force @args }
# Optional interactive guards (uncomment to mimic rm -i / mv -i / cp -i):
# function rm { Remove-Item -Confirm @args }
# function mv { Move-Item   -Confirm @args }
# function cp { Copy-Item   -Confirm @args }

# --- Networking ---
function myip    { Invoke-RestMethod ifconfig.me }
function ports   { Get-NetTCPConnection -State Listen | Sort-Object LocalPort | Format-Table -Auto }
function localip { (Get-NetIPAddress -AddressFamily IPv4 |
                    Where-Object { $_.IPAddress -ne '127.0.0.1' } |
                    Select-Object -First 1).IPAddress }

# --- Git ---
function gitlog { git log --all --pretty=format:'%h %s' --graph }

# --- bat (cat replacement) ---
function cat  { bat --paging=never @args }
Set-Alias catp bat

# --- top (btop has no Windows build; 'bottom' / btm is the equivalent) ---
Set-Alias top btm

# --- eza (ls replacement) ---
function ls  { eza -a --color=always --group-directories-first --icons @args }
function ll  { eza -la --color=always --group-directories-first --icons --octal-permissions @args }
function llm { eza -lbGd --header --git --sort=modified --color=always --group-directories-first --icons @args }
function lx  { eza -lbhHigUmuSa'@' --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons @args }
function lt  { eza --tree --level=2 --color=always --group-directories-first --icons @args }

# --- fd (find replacement) ---
Set-Alias f fd
function ff { fd --type f @args }
function fh { fd --hidden @args }

# --- ripgrep (call rg.exe to avoid recursing into this function) ---
function rg  { & rg.exe --smart-case @args }
function rgi { & rg.exe --no-ignore @args }

# --- zoxide: smart 'cd' + 'cdi' (replaces cd, like your z/zi) ---
Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })

# --- Shell quick edits ---
function editshrc      { & $script:_editor $PROFILE }
function editshaliases { & $script:_editor "$PSScriptRoot\aliases.ps1" }
