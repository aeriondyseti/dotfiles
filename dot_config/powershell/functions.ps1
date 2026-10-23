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
# Watch a file: print its contents, then reprint whenever it's modified.
# Usage: watchfile ./PROGRESS.md   (Ctrl-C to stop)
function watchfile {
  param(
    [Parameter(Mandatory)][string]$Path,
    [int]$IntervalSeconds = 1
  )
  $Path = (Resolve-Path -LiteralPath $Path).Path
  $lastWrite = (Get-Item -LiteralPath $Path).LastWriteTime
  Clear-Host
  Get-Content -LiteralPath $Path
  while ($true) {
    Start-Sleep -Seconds $IntervalSeconds
    $currentWrite = (Get-Item -LiteralPath $Path).LastWriteTime
    if ($currentWrite -ne $lastWrite) {
      Clear-Host
      Write-Host "--- Last Updated: $(Get-Date -Format 'HH:mm:ss') ---" -ForegroundColor Cyan
      Get-Content -LiteralPath $Path
      $lastWrite = $currentWrite
    }
  }
}
# Re-run a command every N seconds, clearing between runs (like Unix `watch`).
# Usage: watch { Get-ChildItem } 5   (Ctrl-C to stop)
function watch {
  param(
    [Parameter(Mandatory)][scriptblock]$Command,
    [int]$Seconds = 2
  )
  while ($true) {
    Clear-Host
    Write-Host "Every ${Seconds}s: $Command`t$(Get-Date)`n"
    & $Command
    Start-Sleep -Seconds $Seconds
  }
}
# dev: jump to a repo (or a folder inside one) under X:\Development. No arg = go
# to the root. X: directly, not the D:\Development junction (Docker-in-WSL can't
# bind-mount through the junction).
# Usage: dev Marinara-Engine   dev Marinara-Engine/src   (Tab completes each level)
$script:_devRoot = 'X:\Development'
function dev {
  param([string]$Repo)
  if (-not $Repo) { Set-Location -LiteralPath $script:_devRoot; return }
  $target = Join-Path $script:_devRoot $Repo
  if (Test-Path -LiteralPath $target -PathType Container) {
    Set-Location -LiteralPath $target
  } else {
    Write-Error "No such directory: $target"
  }
}
# Nested completion like zsh's `_files -/ -W`: completes one level at a time.
Register-ArgumentCompleter -CommandName dev -ParameterName Repo -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete)
  $word   = $wordToComplete.Trim("'", '"') -replace '\\', '/'
  $slash  = $word.LastIndexOf('/')
  $parent = $word.Substring(0, $slash + 1)
  $leaf   = $word.Substring($slash + 1)
  Get-ChildItem -Directory -LiteralPath (Join-Path $script:_devRoot $parent) -ErrorAction SilentlyContinue |
    Where-Object Name -like "$leaf*" |
    ForEach-Object {
      $rel  = "$parent$($_.Name)"
      $text = if ($rel -match '\s') { "'$rel'" } else { $rel }
      [System.Management.Automation.CompletionResult]::new($text, $rel, 'ProviderContainer', $rel)
    }
}

function jqpretty {
  if ($args.Count) { $args[0] | jq . } else { $input | jq . }
}
Set-Alias jqp jqpretty

# shedit: edit a shell config file (Tab completes the name). Usage: shedit aliases
function shedit {
  param([ValidateSet('rc', 'aliases', 'funcs', 'env', 'local')][string]$Which)
  $files = @{
    rc      = "$PSScriptRoot\Microsoft.PowerShell_profile.ps1"   # $PROFILE is just the stub
    aliases = "$PSScriptRoot\aliases.ps1"
    funcs   = "$PSScriptRoot\functions.ps1"
    env     = "$PSScriptRoot\env.ps1"
    local   = "$PSScriptRoot\local.ps1"
  }
  if (-not $Which) { Write-Host 'Usage: shedit {rc|aliases|funcs|env|local}'; return }
  & $env:EDITOR $files[$Which]
}

# gbclean: delete all local branches except main, master, env/*, and the current one.
function gbclean {
  $current  = git branch --show-current
  $branches = @(git branch --format='%(refname:short)' |
    Where-Object { ($_ -notin 'main', 'master', $current) -and ($_ -notlike 'env/*') })
  if ($branches) { git branch -D @branches }
}

# --- Fuzzy stuff (fzf) ---
# Windows has no SIGTERM: the default asks the process to close (taskkill, which
# console apps may refuse); --force/-f terminates it (taskkill /F). --root/-r
# runs taskkill through Windows sudo (Settings > System > For developers).
function _fkillPid {
  param([int]$ProcId, [bool]$Force, [bool]$Elevate)
  $tk = @('/PID', $ProcId)
  if ($Force) { $tk += '/F' }
  if ($Elevate) { sudo taskkill @tk } else { taskkill @tk }
}

# fkill: fuzzy-pick a process and kill it. Usage: fkill [--force|-f]
function fkill {
  $force  = ($args -contains '--force') -or ($args -contains '-f')
  $header = '{0,7}  {1,10}  {2,9}  {3}' -f 'PID', 'CPU(s)', 'MEM(MB)', 'NAME'
  $rows   = Get-Process | Sort-Object CPU -Descending | ForEach-Object {
    '{0,7}  {1,10:N1}  {2,9:N0}  {3}' -f $_.Id, $_.CPU, ($_.WorkingSet64 / 1MB), $_.ProcessName
  }
  $sel = @($header) + $rows | fzf --header-lines=1 --prompt='Kill> '
  if ($sel) { _fkillPid ([int]($sel.Trim() -split '\s+')[0]) $force $false }
}
Set-Alias fkillProc fkill

# fkillport: fuzzy-pick a listening port's owner and kill it.
# Usage: fkillport [--root|-r] [--force|-f]
function fkillport {
  $force = $false; $elevate = $false
  foreach ($a in $args) {
    if ($a -in '--root', '-r') { $elevate = $true }
    elseif ($a -in '--force', '-f') { $force = $true }
    else { Write-Host 'Usage: fkillport [--root|-r] [--force|-f]'; return }
  }
  $names = @{}; Get-Process | ForEach-Object { $names[$_.Id] = $_.ProcessName }
  $socks = @(
    Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
      Select-Object @{ n = 'Proto'; e = { 'tcp' } }, LocalAddress, LocalPort, OwningProcess
    Get-NetUDPEndpoint -ErrorAction SilentlyContinue |
      Select-Object @{ n = 'Proto'; e = { 'udp' } }, LocalAddress, LocalPort, OwningProcess
  ) | Sort-Object Proto, LocalPort, LocalAddress -Unique
  $header = '{0,-5} {1,-45} {2,7}  {3}' -f 'PROTO', 'LOCAL ADDRESS:PORT', 'PID', 'PROCESS'
  $rows = $socks | ForEach-Object {
    '{0,-5} {1,-45} {2,7}  {3}' -f $_.Proto, "$($_.LocalAddress):$($_.LocalPort)", $_.OwningProcess, $names[[int]$_.OwningProcess]
  }
  $sel = @($header) + $rows | fzf --header-lines=1 --prompt='Kill Port> '
  if (-not $sel) { return }
  $procId = [int]($sel.Trim() -split '\s+')[2]
  if ($procId -le 4) { Write-Error "PID $procId is a system process; not killing it."; return }
  _fkillPid $procId $force $elevate
}
Set-Alias fkp fkillport

# fa: fuzzy-find our aliases and functions (not PowerShell's built-ins or module
# internals), with a preview; prints the picked name. Alt+A inserts it at the prompt.
function fa {
  $tmp = Join-Path ([IO.Path]::GetTempPath()) "fa-$PID"
  New-Item -ItemType Directory -Force -Path $tmp | Out-Null
  # Preview text goes in <n>.txt, where n is the line's 0-based position, so the
  # preview can use fzf's {n} (a bare number, no shell-quoting surprises).
  $i = 0
  $lines = @(
    Get-Alias | Where-Object { "$($_.Name)=$($_.Definition)" -notin $script:_builtinAliases } |
      Sort-Object Name | ForEach-Object {
        Set-Content -LiteralPath "$tmp\$i.txt" "# ALIAS: $($_.Name)`n$($_.Definition)"; $i++
        "alias: $($_.Name)=$($_.Definition)"
      }
    Get-ChildItem Function: |
      Where-Object { $_.Name -notin $script:_builtinFunctions -and -not $_.ModuleName -and $_.Name -notlike '_*' } |
      Sort-Object Name | ForEach-Object {
        Set-Content -LiteralPath "$tmp\$i.txt" "# FUNCTION: $($_.Name)`nfunction $($_.Name) {$($_.Definition)}"; $i++
        "func:  $($_.Name)"
      }
  )
  Push-Location -LiteralPath $tmp
  try {
    $sel = $lines | fzf --with-shell 'cmd.exe /s /c' `
      --preview 'bat --color=always --style=plain --language=powershell {n}.txt' --preview-window=down:15
  } finally {
    Pop-Location
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
  }
  if ($sel) { $sel -replace '^(alias|func):\s+', '' -replace '=.*$', '' }
}
if ((Get-Module PSReadLine) -and -not [Console]::IsInputRedirected) {
  Set-PSReadLineKeyHandler -Chord 'Alt+a' -BriefDescription 'fa' `
    -Description 'Fuzzy-pick an alias/function and insert its name' -ScriptBlock {
      $name = fa
      [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
      if ($name) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert($name) }
    }
}

# withTitle: run a command under a persistent title strip pinned to the top of
# the pane, with the command's output scrolling below it. Handy for labeling
# panes that tail server logs / dev servers.
#   withTitle "web-1" bun run dev
# Backed by the sibling withTitle.ts (chezmoi-synced next to this file).
function withTitle {
  if ($args.Count -lt 2) { Write-Error 'Usage: withTitle "<title>" <command> [args...]'; return }
  if (-not (Get-Command bun -ErrorAction SilentlyContinue)) { Write-Error 'withTitle needs bun on PATH'; return }
  bun "$PSScriptRoot\withTitle.ts" @args
}


# Color for the Claude prompt. Change this to tell Windows-native Claude apart
# from your WSL (ubuntu) Claude if you run both at once.
$script:_claudeColor = 'orange'

# --- Claude ---
# c / cc are functions so '/color' lands AFTER your args. The '!'-variants add
# --dangerously-skip-permissions (canonical daily form). cagents! opens the agent
# view (`claude agents`) across every session on the machine, not just this dir.
function c   { claude @args /color $script:_claudeColor }
function cc  { c --continue @args }
function c!  { c --dangerously-skip-permissions @args }
function cc! { cc --dangerously-skip-permissions @args }
function cagents! { claude agents --dangerously-skip-permissions @args }
Set-Alias ca! cagents!

# helper-prompt: the helper-agent system prompt with today's date stamped in
# (PowerShell port of ~/.local/bin/helper-prompt, which is a bash script).
function helper-prompt {
  (Get-Content -Raw -LiteralPath "$HOME\.config\claude\helper-prompt.md") -replace
    '\{\{TODAY\}\}', (Get-Date -Format 'dddd, MMMM dd, yyyy')
}
# chelp: claude with the helper system prompt (zsh uses <(helper-prompt); here a
# temp file, removed when claude exits).
function chelp {
  $prompt = New-TemporaryFile
  try {
    helper-prompt | Set-Content -LiteralPath $prompt -NoNewline -Encoding utf8
    claude --system-prompt-file $prompt.FullName @args /color $script:_claudeColor
  } finally {
    Remove-Item -LiteralPath $prompt -ErrorAction SilentlyContinue
  }
}
function chelp! { chelp --dangerously-skip-permissions @args }

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
