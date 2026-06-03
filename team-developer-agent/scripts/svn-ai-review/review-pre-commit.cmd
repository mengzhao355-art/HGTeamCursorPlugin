@echo off
setlocal EnableExtensions
REM TortoiseSVN Pre-commit: 由 TortoiseSVN 将 %PATH% 等替换为实际路径后传入 %1-%4
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0review-pre-commit.ps1" %1 %2 %3 %4
exit /b %ERRORLEVEL%
