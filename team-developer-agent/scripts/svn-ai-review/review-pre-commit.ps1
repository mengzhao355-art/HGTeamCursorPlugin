#Requires -Version 5.1
<#
.SYNOPSIS
    TortoiseSVN Pre-commit Hook 入口。
.DESCRIPTION
    TortoiseSVN Pre-commit：PATH DEPTH MESSAGEFILE CWD（4 个）
    Manual/Start-commit：PATH MESSAGEFILE CWD（3 个）

    TortoiseSVN 会自动按顺序追加 hook 参数；Command Line 只需填写脚本入口，
    不要手写 %PATH% %DEPTH% %MESSAGEFILE% %CWD%。
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-HookError {
    param([string]$Message)
    [Console]::Error.WriteLine($Message)
}

function Test-UnexpandedTortoisePlaceholder {
    param([string]$Value)
    return ($Value -match '^%(PATH|DEPTH|MESSAGEFILE|CWD)%$')
}

function Test-PathListFileValid {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $false
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    if (Test-Path -LiteralPath $Path -PathType Container) {
        return $false
    }

    return $true
}

function Get-TortoiseSvnHookArgs {
    $hookArgs = @($args)

    # TortoiseSVN always appends hook arguments automatically. If the command line
    # also contains %PATH% %DEPTH% %MESSAGEFILE% %CWD%, those literals arrive first.
    while ($hookArgs.Count -gt 4 -and (Test-UnexpandedTortoisePlaceholder ([string]$hookArgs[0]))) {
        $hookArgs = @($hookArgs | Select-Object -Skip 1)
    }

    return $hookArgs
}

# 解析 TortoiseSVN 参数
$PathListFile = $null
$MessageFile = $null
$WorkingCopyPath = $null
$hookArgs = @(Get-TortoiseSvnHookArgs @args)

switch ($hookArgs.Count) {
    3 {
        $PathListFile = [string]$hookArgs[0]
        $MessageFile = [string]$hookArgs[1]
        $WorkingCopyPath = [string]$hookArgs[2]
    }
    { $_ -ge 4 } {
        $PathListFile = [string]$hookArgs[0]
        $MessageFile = [string]$hookArgs[2]
        $WorkingCopyPath = [string]$hookArgs[3]
    }
    default {
        Write-HookError @"
参数不足（收到 $($hookArgs.Count) 个）。
TortoiseSVN Hook 命令行只需要填写脚本入口：
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""$env:LOCALAPPDATA\ExoscopeTeam\svn-ai-review\review-pre-commit.ps1""
"@
        exit 1
    }
}

if (Test-UnexpandedTortoisePlaceholder $PathListFile) {
    Write-HookError @"
TortoiseSVN 未提供真实 PATH 参数。

Hook Command Line 只需要填写脚本入口，不要手写 %PATH%：
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""$env:LOCALAPPDATA\ExoscopeTeam\svn-ai-review\review-pre-commit.ps1""
"@
    exit 1
}

if (-not (Test-PathListFileValid -Path $PathListFile)) {
    $hint = @"
PATH 参数无效：$PathListFile

常见原因：Hook 命令行手写了占位符，或 TortoiseSVN 未自动追加参数。

请改为：
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""$env:LOCALAPPDATA\ExoscopeTeam\svn-ai-review\review-pre-commit.ps1""
"@
    Write-HookError $hint
    exit 1
}

if (-not (Test-Path -LiteralPath $WorkingCopyPath)) {
    Write-HookError "工作副本目录不存在：$WorkingCopyPath"
    exit 1
}

$files = @(Get-Content -LiteralPath $PathListFile -Encoding UTF8 |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ })

if (@($files).Count -eq 0) {
    exit 0
}

$scriptPath = Join-Path $PSScriptRoot 'Invoke-SvnAiReview.ps1'

& $scriptPath `
    -WorkspacePath $WorkingCopyPath `
    -FileList $files `
    -MessageFile $MessageFile `
    -HookMode

exit $LASTEXITCODE
