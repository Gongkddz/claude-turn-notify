@echo off
setlocal
title turn-notify - Claude Code plugin installer
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" -Source Local
set "notifyExit=%errorlevel%"
echo.
if not "%notifyExit%"=="0" echo Installation failed. Read the message above.
pause
exit /b %notifyExit%
