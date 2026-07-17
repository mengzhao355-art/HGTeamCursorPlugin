#Requires -Version 5.1
<#
.SYNOPSIS
    将 SVN AI 审查脚本部署到稳定路径，并输出 TortoiseSVN Hook 配置说明。
.PARAMETER WorkingCopyPath
    SVN 工作副本根目录（用于生成 Hook 配置示例）。
.PARAMETER Force
    覆盖已有部署目录。
.NOTES
    推荐使用同目录 Deploy-SvnAiReview.ps1（一键：定位插件、部署、检查 CLI、打印本机 Hook）。
#>
[CmdletBinding()]
param(
    [string]$WorkingCopyPath = (Get-Location).Path,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$deploy = Join-Path $PSScriptRoot 'Deploy-SvnAiReview.ps1'
if (Test-Path -LiteralPath $deploy) {
    & $deploy -WorkingCopyPath $WorkingCopyPath -Force:$Force
    exit $LASTEXITCODE
}

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

$hookPs1 = Join-Path $targetDir 'review-pre-commit.ps1'
$wcPath = if (Test-Path -LiteralPath $WorkingCopyPath) {
    (Resolve-Path -LiteralPath $WorkingCopyPath).Path
} else {
    $WorkingCopyPath
}

Write-Host ""
Write-Host "=== TortoiseSVN Pre-commit Hook（推荐配置） ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. TortoiseSVN -> Settings -> Hook Scripts -> Add"
Write-Host "   Hook Type         : Pre-commit"
Write-Host "   Working Copy Path : $wcPath"
Write-Host ""
Write-Host "2. Command Line（不要手写 %PATH% 等；TortoiseSVN 会自动追加）" -ForegroundColor Green
Write-Host ""
$recommended = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$hookPs1`""
Write-Host $recommended -ForegroundColor White
Write-Host ""
Write-Host "3. 勾选 [Wait for the script to finish]"
Write-Host ""
Write-Host "=== 重要 ===" -ForegroundColor Yellow
Write-Host "- Hook 配置在本机 Tortoise（注册表），不会随 SVN 提交共享，团队无路径冲突。"
Write-Host "- 必须用资源管理器 TortoiseSVN -> Commit 提交。"
Write-Host "- Cursor CLI: agent login && agent status"
Write-Host ""
