#requires -Version 5.1
<#
.SYNOPSIS
    One-click installer for the DSH Desktop Shortcut skill.

.DESCRIPTION
    Installs this repository as a DSH skill under <DSH_HOME or ~/.dsh>/skills,
    then (by default) creates the one-click desktop shortcut for DeepSeek
    Harness.

    Works in TWO modes automatically:

      1. LOCAL mode  - you cloned/downloaded the repo and run the script from
         inside it. Uses the files next to this script.
      2. REMOTE mode - the script is piped in via `irm ... | iex`. Since no
         local files exist in that case, it downloads the repository zip from
         GitHub into a temp folder and installs from there.

    How to run:

      # Local (clone first):
      git clone https://github.com/Ning668819/dsh-desktop-shortcut.git
      cd dsh-desktop-shortcut
      powershell -ExecutionPolicy Bypass -File scripts\install.ps1

      # Remote (no clone needed):
      powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Ning668819/dsh-desktop-shortcut/main/scripts/install.ps1 | iex"

.PARAMETER InstallDir
    Where to install the skill. Default: <DSH_HOME or ~/.dsh>\skills\dsh-desktop-shortcut

.PARAMETER SkipShortcut
    Install the skill only; do not create the desktop shortcut.

.PARAMETER ShortcutName
    Passed through to create-shortcut.ps1 (display name of the shortcut).

.PARAMETER Url
    Passed through to create-shortcut.ps1 (web UI address to open).

.PARAMETER RepoUrl
    Base URL of the GitHub repository (zip download source in remote mode).
    Default: https://github.com/Ning668819/dsh-desktop-shortcut

.PARAMETER Branch
    Git branch to fetch in remote mode. Default: main

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
    [string]$Url = 'http://127.0.0.1:3080',
    [string]$RepoUrl = 'https://github.com/Ning668819/dsh-desktop-shortcut',
    [string]$Branch = 'main'
)

$ErrorActionPreference = 'Stop'

$skillName = 'dsh-desktop-shortcut'

# ---------------------------------------------------------------------------
# Determine mode and locate the repository files
# ---------------------------------------------------------------------------
$localRoot = $null
if ($PSScriptRoot) {
    $localRoot = Split-Path -Parent $PSScriptRoot   # .../dsh-desktop-shortcut
    if (-not (Test-Path (Join-Path $localRoot 'SKILL.md'))) { $localRoot = $null }
}

$tempRoot = $null
if (-not $localRoot) {
    Write-Host "Remote mode detected - downloading repository zip..." -ForegroundColor Cyan
    $tempRoot = Join-Path $env:TEMP ("dsh-desktop-shortcut-" + [guid]::NewGuid().ToString('N'))
    $zip = Join-Path $tempRoot 'repo.zip'
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    $zipUrl = "$RepoUrl/archive/refs/heads/$Branch.zip"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $zipUrl -OutFile $zip -UseBasicParsing
    } catch {
        Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        throw "Failed to download repository zip from $zipUrl : $($_.Exception.Message)"
    }
    Expand-Archive -Path $zip -DestinationPath $tempRoot -Force
    $localRoot = Join-Path $tempRoot "$skillName-$Branch"
    if (-not (Test-Path (Join-Path $localRoot 'SKILL.md'))) {
        # fall back to any extracted folder containing SKILL.md
        $localRoot = Get-ChildItem $tempRoot -Directory -Recurse -ErrorAction SilentlyContinue |
            Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } |
            Select-Object -First 1 -ExpandProperty FullName
    }
    if (-not $localRoot) {
        Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        throw "Downloaded archive did not contain a valid skill bundle."
    }
    Write-Host "[ok] downloaded to $localRoot" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# Resolve DSH home
# ---------------------------------------------------------------------------
$dshHome = $env:DSH_HOME
if (-not $dshHome) { $dshHome = Join-Path $HOME '.dsh' }

# ---------------------------------------------------------------------------
# Compute install dir
# ---------------------------------------------------------------------------
if (-not $InstallDir) {
    $InstallDir = Join-Path (Join-Path $dshHome 'skills') $skillName
}

Write-Host "Installing skill to: $InstallDir" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# Copy skill bundle (SKILL.md + scripts + assets)
# ---------------------------------------------------------------------------
if (Test-Path $InstallDir) {
    Remove-Item $InstallDir -Recurse -Force
}
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

foreach ($item in @('SKILL.md', 'scripts', 'assets')) {
    $src = Join-Path $localRoot $item
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $InstallDir $item) -Recurse -Force
        Write-Host "[ok] copied $item" -ForegroundColor Green
    } else {
        Write-Warning "missing $item in bundle: $src"
    }
}

# ---------------------------------------------------------------------------
# Optional: create the desktop shortcut
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Cleanup temp download (remote mode only)
# ---------------------------------------------------------------------------
if ($tempRoot) {
    Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Installation complete." -ForegroundColor Green
Write-Host "  Skill dir : $InstallDir" -ForegroundColor Gray
Write-Host "  Usage     : ask your DSH agent to 'create a desktop shortcut for DSH'," -ForegroundColor Gray
Write-Host "              or double-click the shortcut created on your desktop." -ForegroundColor Gray
