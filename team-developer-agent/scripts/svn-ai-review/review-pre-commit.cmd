@echo off
<<<<<<< HEAD
setlocal EnableExtensions
REM TortoiseSVN Pre-commit: 由 TortoiseSVN 将 %PATH% 等替换为实际路径后传入 %1-%4
=======
REM 兼容旧配置：若 Hook 命令行仍手写 %%PATH%% 等占位符，可通过本文件转发。
REM 推荐改为直接调用 review-pre-commit.ps1，且 Command Line 不附加任何参数。
setlocal EnableExtensions
>>>>>>> ef5ce70 (fix(svn-ai-review): 修正 TortoiseSVN Hook 参数解析与配置说明)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0review-pre-commit.ps1" %1 %2 %3 %4
exit /b %ERRORLEVEL%
