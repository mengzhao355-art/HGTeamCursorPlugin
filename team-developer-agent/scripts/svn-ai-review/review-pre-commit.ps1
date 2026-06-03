#Requires -Version 5.1
<#
.SYNOPSIS
    TortoiseSVN Pre-commit Hook 入口。
.DESCRIPTION
<<<<<<< HEAD
    TortoiseSVN Pre-commit 参数：PATH DEPTH MESSAGEFILE CWD（4 个）
    Manual/Start-commit 参数：PATH MESSAGEFILE CWD（3 个）

    必须通过 TortoiseSVN -> Settings -> Hook Scripts 配置，
    命令行中的 %PATH% 等由 TortoiseSVN 替换，勿使用非 TortoiseSVN 客户端。
=======
    TortoiseSVN Pre-commit：PATH DEPTH MESSAGEFILE CWD（4 个）
    Manual/Start-commit：PATH MESSAGEFILE CWD（3 个）

    TortoiseSVN 会自动按顺序追加 hook 参数；Command Line 只需填写脚本入口，
    不要手写 %PATH% %DEPTH% %MESSAGEFILE% %CWD%。
>>>>>>> ef5ce70 (fix(svn-ai-review): 修正 TortoiseSVN Hook 参数解析与配置说明)
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

<<<<<<< HEAD
=======
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

>>>>>>> ef5ce70 (fix(svn-ai-review): 修正 TortoiseSVN Hook 参数解析与配置说明)
# 解析 TortoiseSVN 参数
$PathListFile = $null
$MessageFile = $null
$WorkingCopyPath = $null
<<<<<<< HEAD

switch ($args.Count) {
    3 {
        $PathListFile = [string]$args[0]
        $MessageFile = [string]$args[1]
        $WorkingCopyPath = [string]$args[2]
    }
    { $_ -ge 4 } {
        $PathListFile = [string]$args[0]
        $MessageFile = [string]$args[2]
        $WorkingCopyPath = [string]$args[3]
    }
    default {
        Write-HookError @"
参数不足（收到 $($args.Count) 个）。
TortoiseSVN Pre-commit 命令行必须为（推荐使用 review-pre-commit.cmd）：
  ...\review-pre-commit.cmd %PATH% %DEPTH% %MESSAGEFILE% %CWD%
=======
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
>>>>>>> ef5ce70 (fix(svn-ai-review): 修正 TortoiseSVN Hook 参数解析与配置说明)
"@
        exit 1
    }
}

if (Test-UnexpandedTortoisePlaceholder $PathListFile) {
    Write-HookError @"
<<<<<<< HEAD
TortoiseSVN 未替换 %PATH%（当前值为字面量 ""%PATH%""）。

请检查：
1. 必须使用 TortoiseSVN 提交（资源管理器右键 TortoiseSVN -> Commit）
2. Hook Type 必须为 Pre-commit（不是 Manual Pre-commit）
3. Command Line 推荐：
   ""$env:LOCALAPPDATA\ExoscopeTeam\svn-ai-review\review-pre-commit.cmd"" %PATH% %DEPTH% %MESSAGEFILE% %CWD%
4. %PATH% %DEPTH% 等不要加引号，不要写成 %%PATH%%
5. 勾选 Wait for the script to finish
=======
TortoiseSVN 未提供真实 PATH 参数。

Hook Command Line 只需要填写脚本入口，不要手写 %PATH%：
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""$env:LOCALAPPDATA\ExoscopeTeam\svn-ai-review\review-pre-commit.ps1""
>>>>>>> ef5ce70 (fix(svn-ai-review): 修正 TortoiseSVN Hook 参数解析与配置说明)
"@
    exit 1
}

<<<<<<< HEAD
if (-not (Test-Path -LiteralPath $PathListFile)) {
    Write-HookError "PATH 文件不存在：$PathListFile"
    exit 1
}

=======
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

>>>>>>> ef5ce70 (fix(svn-ai-review): 修正 TortoiseSVN Hook 参数解析与配置说明)
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
