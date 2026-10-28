# Esporta tutti i driver OEM del Lenovo IdeaPad Slim 5 14Q8X9 (Wi-Fi 7 FastConnect 7800, NPU Hexagon, Adreno GPU, Audio, Touchpad)
# Esegui questo script SUL LENOVO prima di formattare (o copia la cartella Drivers risultante in iso_builder\uup_pkg\Drivers)

$ErrorActionPreference = 'Stop'
$dest = Join-Path $PSScriptRoot "uup_pkg\Drivers\ALL"
New-Item -ItemType Directory -Force -Path $dest | Out-Null

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " ESPORTAZIONE DRIVER OEM LENOVO 14Q8X9 (SNAPDRAGON X PLUS)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "[*] Destinazione: $dest"
Write-Host "[*] Avvio export tramite DISM / Export-WindowsDriver (richiede Amministratore)..."

dism.exe /online /export-driver /destination:"$dest"

Write-Host "[OK] Driver esportati in $dest!" -ForegroundColor Green
Write-Host "[*] Durante la creazione della ISO UUP Dump, questi driver verranno iniettati automaticamente in install.wim e boot.wim."
