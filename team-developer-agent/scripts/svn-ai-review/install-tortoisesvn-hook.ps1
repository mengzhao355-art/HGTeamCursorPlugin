#Requires -Version 5.1
<#
.SYNOPSIS
    将 SVN AI 审查脚本部署到稳定路径，并输出 TortoiseSVN Hook 配置说明。
.PARAMETER WorkingCopyPath
    SVN 工作副本根目录（用于生成 Hook 配置示例）。
.PARAMETER Force
    覆盖已有部署目录。
#>
[CmdletBinding()]
param(
    [string]$WorkingCopyPath = (Get-Location).Path,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sourceDir = $PSScriptRoot
$targetDir = Join-Path $env:LOCALAPPDATA 'ExoscopeTeam\svn-ai-review'

if ((Test-Path $targetDir) -and -not $Force) {
    Write-Host "目标目录已存在：$targetDir" -ForegroundColor Yellow
    Write-Host "使用 -Force 覆盖，或手动删除后重试。"
}
else {
    if (Test-Path $targetDir) {
        Remove-Item $targetDir -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    Copy-Item -Path (Join-Path $sourceDir '*') -Destination $targetDir -Recurse -Force
    Write-Host "已部署脚本到：$targetDir" -ForegroundColor Green
}

$hookCmd = Join-Path $targetDir 'review-pre-commit.cmd'
$wcPath = (Resolve-Path $WorkingCopyPath).Path

Write-Host ""
Write-Host "=== TortoiseSVN Pre-commit Hook 配置（必须用 TortoiseSVN 提交） ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. 打开 TortoiseSVN -> Settings -> Hook Scripts"
Write-Host "2. 点击 Add，填写："
Write-Host "   Hook Type        : Pre-commit  （勿选 Manual Pre-commit）"
Write-Host "   Working Copy Path: E:\project  （建议填 SVN 根目录，非 zmDevelop 子目录）"
Write-Host "   当前示例路径      : $wcPath"
Write-Host "   Command Line     : （整行复制，%PATH% 等由 TortoiseSVN 自动替换）"
Write-Host ""
Write-Host "`"$hookCmd`" %PATH% %DEPTH% %MESSAGEFILE% %CWD%" -ForegroundColor White
Write-Host ""
Write-Host "   错误示例（会导致 PATH 文件不存在 %PATH%）："
Write-Host "   - 直接运行 powershell ... review-pre-commit.ps1（无 TortoiseSVN 传参）"
Write-Host "   - 使用 Visual Studio / 命令行 svn commit（不触发 TortoiseSVN Hook）"
Write-Host "   - 将 %PATH% 写成 %%PATH%% 或加多余引号"
Write-Host ""
Write-Host "3. 勾选 [Wait for the script to finish]"
Write-Host "4. 确保已安装 Cursor CLI："
Write-Host "     irm 'https://cursor.com/install?win32=true' | iex"
Write-Host "     agent login"
Write-Host ""
Write-Host "=== 手动审查（IDE 或终端） ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$(Join-Path $targetDir 'Invoke-SvnAiReview.ps1')`" -WorkspacePath `"$wcPath`""
Write-Host ""
Write-Host "=== 项目侧建议 ===" -ForegroundColor Cyan
Write-Host "- 将 .review/ 加入 svn:ignore（运行时 diff 与报告不入库）"
Write-Host "- 可选：在工作副本根创建 review-config.local.json 覆盖 gateMode 等配置"
Write-Host ""
