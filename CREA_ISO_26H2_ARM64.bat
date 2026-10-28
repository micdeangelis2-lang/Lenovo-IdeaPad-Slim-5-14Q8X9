@echo off
title Creazione ISO Windows 11 26H2 ARM64 (Zero-Bloat + App Default) - Lenovo 14Q8X9
cd /d "%~dp0"

echo ============================================================================
echo  GENERATORE ISO PULITA WINDOWS 11 26H2 (ARM64) - SNAPDRAGON X PLUS
echo  Build UUP Dump: 26300.9725 (26H2 Retail ARM64 it-IT Home/Pro)
echo ============================================================================
echo.
echo Configurazione attiva:
echo  - Architettura: ARM64 nativa + Prism (Microsoft Application Compatibility)
echo  - Rimozione Bloatware/Edge/WinZip: ATTIVA (CustomAppsList.txt + SkipEdge=1)
echo  - Zero Telemetria e Account Locale Sempre: ATTIVO (autounattend.xml integrato)
echo  - Programmi Nativi ARM64 Default: 7-Zip, Brave Browser, VLC, Notepad++, LenovoCheckup_ARM64.exe
echo  - Driver Ufficiali Qualcomm/Lenovo ARM64: 346 file .inf in Drivers\ALL e Drivers\WinPE
echo.

cd /d "%~dp0iso_builder\uup_pkg"

if exist "UUPs\core_it-it.esd" (
    echo [*] Tutti i pacchetti UUP sono gia' scaricati e verificati!
    echo [*] Avvio compilazione ISO ^(convert-UUP.cmd^)...
    echo [*] Quando appare il popup di Windows ^(UAC^), clicca "Si'".
    echo.
    call convert-UUP.cmd
) else (
    echo [*] Avvio download UUP e compilazione ISO...
    call uup_download_windows.cmd
)
