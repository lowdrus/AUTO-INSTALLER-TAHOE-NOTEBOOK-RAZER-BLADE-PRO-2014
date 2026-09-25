@echo off
setlocal
cd /d "%~dp0"
title LOWDRUS INSTALLER
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0src\manager\Lowdrus.Manager.ps1"
if errorlevel 1 (
  echo.
  echo [LOWDRUS] A interface foi encerrada com erro.
  echo Consulte reports\windows e o README para diagnostico.
  pause
)
endlocal
