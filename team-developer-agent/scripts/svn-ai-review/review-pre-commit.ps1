#Requires -Version 5.1
<#
.SYNOPSIS
    TortoiseSVN Pre-commit Hook 入口。
.DESCRIPTION
    参数顺序（TortoiseSVN Pre-commit）：PATH DEPTH MESSAGEFILE CWD
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$PathListFile,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$Depth,

    [Parameter(Mandatory = $true, Position = 2)]
    [string]$MessageFile,

    [Parameter(Mandatory = $true, Position = 3)]
    [string]$WorkingCopyPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path $PathListFile)) {
    [Console]::Error.WriteLine("PATH 文件不存在：$PathListFile")
    exit 1
}

$files = Get-Content $PathListFile -Encoding UTF8 |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ }

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
