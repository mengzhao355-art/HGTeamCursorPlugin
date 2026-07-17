@echo off
REM TortoiseSVN Hook 推荐直接调用 review-pre-commit.ps1，且 Command Line 不附加任何参数。
REM 若仍使用本 .cmd：Command Line 只填本文件路径，不要手写 %PATH%（TortoiseSVN 会自动追加）。
setlocal EnableExtensions
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0review-pre-commit.ps1" %*
exit /b %ERRORLEVEL%
