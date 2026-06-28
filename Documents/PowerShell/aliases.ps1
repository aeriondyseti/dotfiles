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
# rmrf: robust recursive delete. Uses native 'rmdir /s /q' for directories so it
# handles read-only files (git objects) and deep paths (node_modules) that
# Remove-Item chokes on. Files fall back to Remove-Item -Force. Supports globs.
function rmrf {
  foreach ($p in $args) {
    $items = Resolve-Path -Path $p -ErrorAction SilentlyContinue
    if (-not $items) { Write-Warning "rmrf: not found: $p"; continue }
    foreach ($item in $items) {
      $path = $item.Path
      if (Test-Path -LiteralPath $path -PathType Container) {
        & cmd /c "rmdir /s /q `"$path`""
      } else {
        Remove-Item -LiteralPath $path -Force
      }
    }
  }
}
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
# Windows system-file noise hidden from the default 'ls' (registry hives etc.).
# Single-quoted so $RECYCLE.BIN is literal, not a variable. '|'-separated globs.
$script:_ezaSysIgnore = 'NTUSER*|ntuser*|desktop.ini|Thumbs.db|$RECYCLE.BIN|System Volume Information|hiberfil.sys|pagefile.sys|swapfile.sys'

# ls: dotfiles shown, Windows system files hidden. Passes through flags/paths.
function ls  { eza -a --ignore-glob $script:_ezaSysIgnore --group-directories-first --icons=always --color=always @args }
# la: everything, including system files.
function la  { eza -a --group-directories-first --icons=always --color=always @args }
# ll: long view, system files hidden (like ls). lla: long view, everything.
function ll  { eza -la --octal-permissions --ignore-glob $script:_ezaSysIgnore --group-directories-first --icons=always --color=always @args }
function lla { eza -la --octal-permissions --group-directories-first --icons=always --color=always @args }
function llm { eza -lbGd --header --git --sort=modified --group-directories-first --icons=always --color=always @args }
function lx  { eza -lbhHigUmuSa'@' --time-style=long-iso --git --color-scale --group-directories-first --icons=always --color=always @args }
function lt  { eza --tree --level=2 --group-directories-first --icons=always --color=always @args }

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
