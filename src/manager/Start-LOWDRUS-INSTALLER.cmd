@echo off
setlocal
cd /d "%~dp0"
start "" powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0Lowdrus.Manager.ps1"
exit /b 0
