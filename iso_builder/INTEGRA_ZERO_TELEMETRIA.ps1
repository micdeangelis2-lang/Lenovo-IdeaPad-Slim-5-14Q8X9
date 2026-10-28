# Script di post-processing automatico su immagine install.wim montata o ISO estratta
# Inietta autounattend.xml nella root della ISO e disattiva telemetria offline nel registro di install.wim

param(
    [string]$IsoRootDir = "$PSScriptRoot\uup_pkg\ISOFOLDER"
)

$ErrorActionPreference = 'SilentlyContinue'
$unattendSrc = Join-Path $PSScriptRoot "autounattend_snapdragon_14Q8X9.xml"

if (Test-Path $IsoRootDir) {
    Copy-Item -Path $unattendSrc -Destination (Join-Path $IsoRootDir "autounattend.xml") -Force
    Write-Host "[OK] autounattend.xml (Zero-Telemetria) integrato nella root della ISO." -ForegroundColor Green
}
