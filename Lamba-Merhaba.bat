@echo off
if /i "%~1"=="--check" goto check
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0launch.ps1"
exit /b %errorlevel%
:check
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0launch.ps1" -Check
exit /b %errorlevel%

