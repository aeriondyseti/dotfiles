# aliases.ps1 — managed by chezmoi (Windows). PowerShell 7 port of aliases.zsh.
# Dot-sourced from Microsoft.PowerShell_profile.ps1.

# --- free up built-in aliases so our functions can take their names ---
'ls','cat','cp','mv','rm','man' | ForEach-Object {
  if (Test-Path "Alias:$_") { Remove-Item "Alias:$_" -Force }
}

# (EDITOR/VISUAL are set in env.ps1, which the profile sources before this file.)

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

# --- chezmoi ---
Set-Alias chm chezmoi

# --- Shell quick edits ---
function editshrc      { & $env:EDITOR $PROFILE }
function editshenv     { & $env:EDITOR "$PSScriptRoot\env.ps1" }
function editshaliases { & $env:EDITOR "$PSScriptRoot\aliases.ps1" }
function editshfuncs   { & $env:EDITOR "$PSScriptRoot\functions.ps1" }
function shreload      { . $PROFILE }

# --- Linux muscle-memory ---
function which   { (Get-Command @args -ErrorAction SilentlyContinue).Source }
function touch   { foreach ($f in $args) { if (Test-Path $f) { (Get-Item $f).LastWriteTime = Get-Date } else { New-Item -ItemType File -Path $f | Out-Null } } }
function pbcopy  { $input | Set-Clipboard }      # echo x | pbcopy
function pbpaste { Get-Clipboard }
function env     { Get-ChildItem Env: }
Set-Alias open Invoke-Item                       # open . / open file (xdg-open/open)
Set-Alias grep rg                                # muscle memory -> ripgrep
# man -> tldr (falls back to Get-Help if tldr isn't installed)
function man { if (Get-Command tldr -ErrorAction SilentlyContinue) { tldr @args } else { Microsoft.PowerShell.Core\Get-Help @args } }

# --- oh-my-posh ---
Set-Alias omp oh-my-posh

# --- Docker (needs Docker Desktop) ---
Set-Alias d docker
function dps  { docker ps @args }
function dls  { docker ps    --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}' @args }
function dlsa { docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}' @args }
function di   { docker images @args }
function dv   { docker volume ls @args }
function dn   { docker network ls @args }

# --- Docker Compose ---
function dc   { docker compose @args }
function dcu  { docker compose up -d @args }
function dcd  { docker compose down @args }
function dcl  { docker compose logs -f @args }
function dcr  { docker compose restart @args }
function dcb  { docker compose build @args }
function dce  { docker compose exec @args }

# --- lazydocker / lazygit ---
Set-Alias lzd lazydocker
Set-Alias lg  lazygit
