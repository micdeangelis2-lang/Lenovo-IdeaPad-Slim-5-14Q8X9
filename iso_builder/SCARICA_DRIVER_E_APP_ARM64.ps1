# Script automatico per scaricare ed estrarre tutti i 346 driver ufficiali Lenovo/Qualcomm ARM64
# e le app native ARM64 (7-Zip, Brave Browser, VLC, Notepad++) prima della creazione della ISO

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$drvDir = Join-Path $PSScriptRoot "uup_pkg\Drivers"
$appDir = Join-Path $PSScriptRoot "oem_apps"
$biosDir = Join-Path $root "BIOS_Update_14Q8X9"
$tmpDl = Join-Path $env:TEMP "lenovo_14q8x9_dl"

New-Item -ItemType Directory -Force -Path $drvDir, $appDir, $biosDir, $tmpDl | Out-Null

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host " DOWNLOAD AUTOMATICO DRIVER QUALCOMM SNAPDRAGON X & APP NATIVE ARM64" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

# 1. Download innoextract 1.9
$innoZip = Join-Path $tmpDl "innoextract.zip"
$innoBin = Join-Path $tmpDl "inno_bin\innoextract.exe"
if (-not (Test-Path $innoBin)) {
    Write-Host "[*] Scaricamento innoextract 1.9..."
    curl.exe -s -L "https://github.com/dscharrer/innoextract/releases/download/1.9/innoextract-1.9-windows.zip" -o $innoZip
    Expand-Archive -Path $innoZip -DestinationPath (Join-Path $tmpDl "inno_bin") -Force
}

# 2. Download BIOS PUCN55WW per IdeaPad Slim 5 14Q8X9 (Type 83HL)
Write-Host "[*] Scaricamento BIOS ufficiale PUCN55WW (14Q8X9)..."
curl.exe -s -L "https://download.lenovo.com/consumer/mobiles/pucn55ww.exe" -o (Join-Path $biosDir "BIOS_IdeaPad_14Q8X9_pucn55ww.exe")
curl.exe -s -L "https://download.lenovo.com/consumer/mobiles/pucn55ww.txt" -o (Join-Path $biosDir "BIOS_IdeaPad_14Q8X9_pucn55ww.txt")

# 3. Download & Extract Driver Packs
$packages = @(
    @{ Name = "WinPE_Core"; Url = "https://download.lenovo.com/pccbbs/mobiles/tp_8cxg4_pe11_202507.exe" },
    @{ Name = "Fingerprint"; Url = "https://download.lenovo.com/pccbbs/mobiles/n42gf12w.exe" },
    @{ Name = "WMI_ACPI"; Url = "https://download.lenovo.com/pccbbs/mobiles/n42ab08w.exe" },
    @{ Name = "Power_Battery"; Url = "https://download.lenovo.com/pccbbs/mobiles/n1fupa3w.exe" },
    @{ Name = "Base_Utility"; Url = "https://download.lenovo.com/pccbbs/mobiles/r19vu23w.exe" },
    @{ Name = "Qualcomm_Integrated"; Url = "https://download.lenovo.com/pccbbs/mobiles/n42qq22w.exe" },
    @{ Name = "SCCM_25H2_202609"; Url = "https://download.lenovo.com/pccbbs/mobiles/tp_t14s_gen6_21n1-21n2_w11_25_202609.exe" }
)

foreach ($pkg in $packages) {
    $exePath = Join-Path $tmpDl "$($pkg.Name).exe"
    $outPath = Join-Path $drvDir $pkg.Name
    Write-Host "[*] Scaricamento ed estrazione driver $($pkg.Name)..."
    curl.exe -s -L $pkg.Url -o $exePath
    & $innoBin -s -e -d $outPath $exePath
}

# 4. Download Native ARM64 Default Apps
Write-Host "[*] Scaricamento installer nativi ARM64 (7-Zip, Notepad++, VLC, Brave)..."
curl.exe -s -L "https://github.com/ip7z/7zip/releases/download/26.05/7z2605-arm64.exe" -o (Join-Path $appDir "7zip_arm64.exe")
curl.exe -s -L "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.9.8.1/npp.8.9.8.1.Installer.arm64.exe" -o (Join-Path $appDir "notepadpp_arm64.exe")
curl.exe -s -L "https://get.videolan.org/vlc/last/winarm64/vlc-3.0.24-winarm64.exe" -o (Join-Path $appDir "vlc_arm64.exe")
curl.exe -s -L "https://github.com/brave/brave-browser/releases/download/v1.98.62/BraveBrowserStandaloneSilentSetupArm64.exe" -o (Join-Path $appDir "BraveStandaloneSilentArm64.exe")

$infCount = (Get-ChildItem -Recurse $drvDir -Filter "*.inf").Count
Write-Host "[OK] Completato! $infCount driver .inf estratti in $drvDir e app ARM64 pronte in $appDir." -ForegroundColor Green
