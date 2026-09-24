@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Lowdrus.Manager.ps1"
if errorlevel 1 (
 echo.
 echo LOWDRUS INSTALLER nao conseguiu iniciar.
 pause
)
