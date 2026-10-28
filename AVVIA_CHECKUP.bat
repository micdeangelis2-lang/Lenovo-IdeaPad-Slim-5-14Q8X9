@echo off
title Lenovo IdeaPad Slim 5 14Q8X9 - Hardware Checkup Suite
cd /d "%~dp0"

echo ============================================================
echo  LENOVO IDEAPAD SLIM 5 14Q8X9 - CHECKUP USATO E PERIFERICHE
echo ============================================================

if exist ".venv\Scripts\python.exe" (
    echo [*] Avvio tramite ambiente virtuale locale ^(.venv^)...
    ".venv\Scripts\python.exe" backend\server.py
) else (
    echo [*] Creazione ambiente virtuale .venv per questo PC...
    python -m venv .venv
    ".venv\Scripts\python.exe" -m pip install -r requirements.txt
    ".venv\Scripts\python.exe" backend\server.py
)
pause
