#requires -Version 5.1
<#
.SYNOPSIS
    One-click installer for the DSH Desktop Shortcut skill.

.DESCRIPTION
    Installs this repository as a DSH skill under <DSH_HOME or ~/.dsh>/skills,
    then (by default) creates the one-click desktop shortcut for DeepSeek
    Harness.

    Two ways to run:

      1. Local clone:
         git clone https://github.com/Ning668819/dsh-desktop-shortcut.git
         cd dsh-desktop-shortcut
         powershell -ExecutionPolicy Bypass -File scripts\install.ps1

      2. Remote (no clone needed, downloads the latest release):
         powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Ning668819/dsh-desktop-shortcut/main/scripts/install.ps1 | iex"

.PARAMETER InstallDir
    Where to install the skill. Default: <DSH_HOME or ~/.dsh>\skills\dsh-desktop-shortcut

.PARAMETER SkipShortcut
    Install the skill only; do not create the desktop shortcut.

.PARAMETER ShortcutName
    Passed through to create-shortcut.ps1 (display name of the shortcut).

.PARAMETER Url
    Passed through to create-shortcut.ps1 (web UI address to open).

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\install.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -SkipShortcut

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -ShortcutName "My DSH"
#>
[CmdletBinding()]
param(
    [string]$InstallDir = '',
    [switch]$SkipShortcut,
    [string]$ShortcutName = 'DSH 网页启动',
    [string]$Url = 'http://127.0.0.1:3080'
)

$ErrorActionPreference = 'Stop'

# --- Locate this repo ----------------------------------------------------------
$repoRoot = Split-Path -Parent $PSScriptRoot   # .../dsh-desktop-shortcut
$skillName = 'dsh-desktop-shortcut'

# --- Resolve DSH home -----------------------------------------------------------
$dshHome = $env:DSH_HOME
if (-not $dshHome) { $dshHome = Join-Path $HOME '.dsh' }

# --- Compute install dir ----------------------------------------------------------
if (-not $InstallDir) {
    $InstallDir = Join-Path (Join-Path $dshHome 'skills') $skillName
}

Write-Host "Installing skill to: $InstallDir" -ForegroundColor Cyan

# --- Copy skill bundle (SKILL.md + scripts + assets) -------------------------------
if (Test-Path $InstallDir) {
    Remove-Item $InstallDir -Recurse -Force
}
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

foreach ($item in @('SKILL.md', 'scripts', 'assets')) {
    $src = Join-Path $repoRoot $item
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $InstallDir $item) -Recurse -Force
        Write-Host "[ok] copied $item" -ForegroundColor Green
    }
}

# --- Optional: create the desktop shortcut -----------------------------------------
if (-not $SkipShortcut) {
    Write-Host ""
    $creator = Join-Path $InstallDir 'scripts\create-shortcut.ps1'
    if (Test-Path $creator) {
        & $creator -ShortcutName $ShortcutName -Url $Url
    } else {
        Write-Warning "create-shortcut.ps1 not found at $creator; skipping shortcut creation."
    }
} else {
    Write-Host ""
    Write-Host "Skill installed (shortcut skipped)." -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Installation complete." -ForegroundColor Green
Write-Host "  Skill dir : $InstallDir" -ForegroundColor Gray
Write-Host "  Usage     : ask your DSH agent to 'create a desktop shortcut for DSH'," -ForegroundColor Gray
Write-Host "              or double-click the shortcut created on your desktop." -ForegroundColor Gray
