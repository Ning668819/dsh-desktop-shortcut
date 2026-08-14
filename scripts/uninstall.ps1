#requires -Version 5.1
<#
.SYNOPSIS
    Uninstall the DSH Desktop Shortcut skill and desktop shortcut.

.DESCRIPTION
    Removes:
      1. The desktop shortcut (default name "DSH 网页启动")
      2. The installed skill directory
         (<DSH_HOME or ~/.dsh>/skills/dsh-desktop-shortcut)
      3. The generated launcher script (<DSH_HOME or ~/.dsh>/start-web.ps1)
      4. (Optionally) the repository copy this script lives in

    Nothing else is touched. Safe to re-run; missing items are skipped.

.PARAMETER ShortcutName
    The shortcut name to remove. Default: DSH 网页启动

.PARAMETER InstallDir
    The skill directory to remove. Default:
    <DSH_HOME or ~/.dsh>/skills/dsh-desktop-shortcut

.PARAMETER RemoveLauncher
    Also remove the generated launcher script
    (<DSH_HOME or ~/.dsh>/start-web.ps1). Default: $true

.PARAMETER RemoveRepo
    Also delete the repository folder this script lives in after
    uninstalling. Default: $false

.PARAMETER Yes
    Skip the confirmation prompt.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\uninstall.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\uninstall.ps1 -Yes

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\uninstall.ps1 -ShortcutName "My DSH" -Yes
#>
[CmdletBinding()]
param(
    [string]$ShortcutName = 'DSH 网页启动',
    [string]$InstallDir = '',
    [switch]$RemoveLauncher = $true,
    [switch]$RemoveRepo,
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'

# --- Resolve DSH home ---------------------------------------------------------
$dshHome = $env:DSH_HOME
if (-not $dshHome) { $dshHome = Join-Path $HOME '.dsh' }

# --- Compute default install dir -----------------------------------------------
if (-not $InstallDir) {
    $InstallDir = Join-Path (Join-Path $dshHome 'skills') 'dsh-desktop-shortcut'
}

$desktop = [Environment]::GetFolderPath('Desktop')
if (-not $desktop) { $desktop = Join-Path $HOME 'Desktop' }
$lnkPath = Join-Path $desktop "$ShortcutName.lnk"
$launcherPath = Join-Path $dshHome 'start-web.ps1'

# --- Confirmation ---------------------------------------------------------------
Write-Host "This will remove:" -ForegroundColor Yellow
Write-Host "  - Shortcut : $lnkPath"
Write-Host "  - Skill dir: $InstallDir"
Write-Host "  - Launcher : $launcherPath"
if ($RemoveRepo) {
    Write-Host "  - Repo copy: $PSScriptRoot"
}
if (-not $Yes) {
    $answer = Read-Host "Continue? [y/N]"
    if ($answer -notmatch '^[yY]') {
        Write-Host "Aborted - nothing was removed." -ForegroundColor Cyan
        exit 0
    }
}

# --- Remove items ---------------------------------------------------------------
$removed = 0
if (Test-Path $lnkPath) {
    Remove-Item $lnkPath -Force
    Write-Host "[ok] removed shortcut: $lnkPath" -ForegroundColor Green
    $removed++
} else {
    Write-Host "[..] shortcut not found, skipping: $lnkPath" -ForegroundColor DarkGray
}

if (Test-Path $InstallDir) {
    Remove-Item $InstallDir -Recurse -Force
    Write-Host "[ok] removed skill dir: $InstallDir" -ForegroundColor Green
    $removed++
} else {
    Write-Host "[..] skill dir not found, skipping: $InstallDir" -ForegroundColor DarkGray
}

if ($RemoveLauncher -and (Test-Path $launcherPath)) {
    Remove-Item $launcherPath -Force
    Write-Host "[ok] removed launcher: $launcherPath" -ForegroundColor Green
    $removed++
} elseif ($RemoveLauncher) {
    Write-Host "[..] launcher not found, skipping: $launcherPath" -ForegroundColor DarkGray
}

if ($RemoveRepo -and (Test-Path $PSScriptRoot)) {
    $repoDir = Split-Path -Parent $PSScriptRoot
    if ($repoDir -and (Test-Path $repoDir) -and (Split-Path -Leaf $repoDir) -eq 'dsh-desktop-shortcut') {
        Remove-Item $repoDir -Recurse -Force
        Write-Host "[ok] removed repo: $repoDir" -ForegroundColor Green
        $removed++
    }
}

# --- Refresh icon cache (best effort) -------------------------------------------
$ie = "$env:SystemRoot\System32\ie4uinit.exe"
if (Test-Path $ie) {
    try { & $ie -show 2>$null | Out-Null } catch { }
}

Write-Host ""
if ($removed -gt 0) {
    Write-Host "Uninstall complete ($removed item(s) removed)." -ForegroundColor Green
} else {
    Write-Host "Nothing to remove - already clean." -ForegroundColor Cyan
}
