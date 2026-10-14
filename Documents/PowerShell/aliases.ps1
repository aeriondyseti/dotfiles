# aliases.ps1 — managed by chezmoi (Windows). PowerShell 7 port of aliases.zsh.
# Dot-sourced from Microsoft.PowerShell_profile.ps1.

# Snapshot of PowerShell's built-in aliases/functions, taken before we change
# anything, so 'fa' (functions.ps1) lists only ours.
$script:_builtinAliases   = @(Get-Alias | ForEach-Object { "$($_.Name)=$($_.Definition)" })
$script:_builtinFunctions = @((Get-ChildItem Function:).Name)

# --- free up built-in aliases so our functions can take their names ---
'ls','cat','cp','mv','rm','man' | ForEach-Object {
  if (Test-Path "Alias:$_") { Remove-Item "Alias:$_" -Force }
}

# --- GNU coreutils (uutils, installed via winget) ---
# winget links each utility (rm.exe, mv.exe, mkdir.exe, ...) into WinGet\Links.
# Drop the PowerShell aliases/functions that shadow them so rm -rf, mkdir -p,
# tee -a, sort -u etc. behave like Linux. echo/pwd/sleep/cd stay PowerShell;
# ls/cat stay eza/bat (below).
$script:_uutils    = "$env:LOCALAPPDATA\Microsoft\WinGet\Links"
$script:_hasUutils = Test-Path "$script:_uutils\sort.exe"
if ($script:_hasUutils) {
  'rmdir','tee','sort' | ForEach-Object {
    if (Test-Path "Alias:$_") { Remove-Item "Alias:$_" -Force }
  }
  if (Test-Path Function:mkdir) { Remove-Item Function:mkdir }
  # System32\sort.exe precedes WinGet\Links on PATH; point at GNU sort explicitly.
  Set-Alias sort "$script:_uutils\sort.exe"
}

# (EDITOR/VISUAL are set in env.ps1, which the profile sources before this file.)

# --- General ('cls' is already built-in Clear-Host) ---
function path { $env:PATH -split ';' }
function now  { Get-Date -Format 'yyyy-MM-dd HH:mm:ss' }

# --- Safety nets / force variants ---
if ($script:_hasUutils) {
  # Same as aliases.zsh. GNU rm -rf handles read-only git objects and >260-char
  # paths, and uutils expands globs itself (PowerShell doesn't for native exes).
  function rm   { & "$script:_uutils\rm.exe" -i @args }
  function mv   { & "$script:_uutils\mv.exe" -i @args }
  function cp   { & "$script:_uutils\cp.exe" -i @args }
  function rmrf { & "$script:_uutils\rm.exe" -rf @args }
  function mvf  { & "$script:_uutils\mv.exe" -f @args }
  function cpf  { & "$script:_uutils\cp.exe" -f @args }
} else {
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
}

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
function pbcopy  { $input | Set-Clipboard }      # echo x | pbcopy
function pbpaste { Get-Clipboard }
# touch/env: GNU versions from uutils when installed; PowerShell fallbacks otherwise.
if (-not $script:_hasUutils) {
  function touch { foreach ($f in $args) { if (Test-Path $f) { (Get-Item $f).LastWriteTime = Get-Date } else { New-Item -ItemType File -Path $f | Out-Null } } }
  function env   { Get-ChildItem Env: }
}
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

# --- Bun ('bun x' == bunx) ---
function b   { bun @args }
function br  { bun run @args }
function bx  { bun x @args }
function bi  { bun install @args }
function ba  { bun add @args }
function bad { bun add -d @args }

# --- uv ---
function uvr  { uv run @args }
function uvs  { uv sync @args }
function uva  { uv add @args }
function uvad { uv add --dev @args }
function uvp  { uv pip @args }
