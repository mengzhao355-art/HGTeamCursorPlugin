#Requires -Version 5.1
<#
.SYNOPSIS
    TortoiseSVN Pre-commit Hook 入口。
.DESCRIPTION
    参数顺序（TortoiseSVN Pre-commit）：PATH DEPTH MESSAGEFILE CWD

    注意：DEPTH 常为 -2 / -1 等负数，不能用 param 块接收（PowerShell 会当作开关参数），
    必须使用 $args 按位置读取。
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($args.Count -lt 4) {
    [Console]::Error.WriteLine("参数不足。TortoiseSVN Pre-commit 需要 4 个参数：PATH DEPTH MESSAGEFILE CWD")
    exit 1
}

$PathListFile = [string]$args[0]
$MessageFile = [string]$args[2]
$WorkingCopyPath = [string]$args[3]

if (-not (Test-Path -LiteralPath $PathListFile)) {
    [Console]::Error.WriteLine("PATH 文件不存在：$PathListFile")
    exit 1
}

if (-not (Test-Path -LiteralPath $WorkingCopyPath)) {
    [Console]::Error.WriteLine("工作副本目录不存在：$WorkingCopyPath")
    exit 1
}

$files = @(Get-Content -LiteralPath $PathListFile -Encoding UTF8 |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ })

if ($files.Count -eq 0) {
    exit 0
}

$scriptPath = Join-Path $PSScriptRoot 'Invoke-SvnAiReview.ps1'

& $scriptPath `
    -WorkspacePath $WorkingCopyPath `
    -FileList $files `
    -MessageFile $MessageFile `
    -HookMode

exit $LASTEXITCODE
