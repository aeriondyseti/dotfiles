#Requires -RunAsAdministrator
# One-time Windows dev setup that needs elevation (chezmoi apply isn't elevated,
# so this is run by hand). Run in an ADMIN PowerShell:
#   sudo pwsh -File scripts\windows-admin-setup.ps1
# or right-click pwsh -> Run as administrator, then dot-source / -File this.

$ErrorActionPreference = 'Stop'

# 1. NTFS long paths (>260 chars) — fixes deep node_modules/.git delete+checkout
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' `
  -Name LongPathsEnabled -Value 1 -Type DWord
Write-Host "[ok] LongPathsEnabled = 1"

# 2. Developer Mode — lets git and mklink create symlinks without elevation
$devKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
New-Item -Path $devKey -Force | Out-Null
Set-ItemProperty $devKey -Name AllowDevelopmentWithoutDevLicense -Value 1 -Type DWord
Write-Host "[ok] Developer Mode enabled (symlinks without admin)"

# 3. OpenSSH agent — autostart so loaded keys persist across sessions
Set-Service ssh-agent -StartupType Automatic
Start-Service ssh-agent
Write-Host "[ok] ssh-agent: startup=Automatic, started"

Write-Host "`nDone. Restart your shell (and any running git) for long paths to apply."
