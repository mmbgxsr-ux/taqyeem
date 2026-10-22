@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo Downloading libraries and fonts...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0get-libs.ps1"
if errorlevel 1 (echo. & echo FAILED. Check your internet connection and try again.) else (echo. & echo Finished successfully.)
pause
