#Requires -Version 5.1
<#
.SYNOPSIS
    SVN 变更 AI 代码审查核心逻辑（Hook 与手动模式共用）。
.PARAMETER WorkspacePath
    SVN 工作副本根目录。
.PARAMETER FileList
    待审查文件路径列表。
.PARAMETER MessageFile
    TortoiseSVN 提交说明临时文件路径（可选）。
.PARAMETER MessageText
    提交说明文本（可选，优先于 MessageFile）。
.PARAMETER HookMode
    为 $true 时显示确认对话框并返回退出码语义的结果对象。
.PARAMETER ConfigPath
    自定义配置文件路径（可选）。
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$WorkspacePath,

    [string[]]$FileList = @(),

    [string]$MessageFile,
    [string]$MessageText,

    [switch]$HookMode,
    [string]$ConfigPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir = $PSScriptRoot
. (Join-Path $scriptDir 'Resolve-PluginRoot.ps1')
. (Join-Path $scriptDir 'Show-ReviewDialog.ps1')

function Write-ReviewError {
    param([string]$Message)
    [Console]::Error.WriteLine($Message)
}

function Test-AgentCliAvailable {
    $agentCmd = Get-Command agent -ErrorAction SilentlyContinue
    if (-not $agentCmd) {
        return $false
    }
    & agent status 2>&1 | Out-Null
    return $LASTEXITCODE -eq 0
}

function Get-ReviewConfig {
    param(
        [string]$Workspace,
        [string]$DefaultConfigPath,
        [string]$OverrideConfigPath
    )

    $config = @{
        gateMode               = 'advisory'
        maxDiffLines           = 3000
        agentTimeoutSeconds    = 180
        skipExtensions         = @('.png', '.jpg', '.jpeg', '.gif', '.dll', '.exe', '.pdb')
        openReportAfterReview  = $true
        criticalMarker         = '🔴 必须修复'
        warningMarker          = '🟡 建议修复'
        suggestionMarker       = '🟢 优化建议'
    }

    if (Test-Path $DefaultConfigPath) {
        $defaults = Get-Content $DefaultConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($prop in $defaults.PSObject.Properties) {
            $config[$prop.Name] = $prop.Value
        }
    }

    $localConfig = Join-Path $Workspace 'review-config.local.json'
    if ($OverrideConfigPath -and (Test-Path $OverrideConfigPath)) {
        $localConfig = $OverrideConfigPath
    }
    if (Test-Path $localConfig) {
        $local = Get-Content $localConfig -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($prop in $local.PSObject.Properties) {
            $config[$prop.Name] = $prop.Value
        }
    }

    return $config
}

function Get-SvnChangedFiles {
    param([string]$Root)

    Push-Location $Root
    try {
        $output = & svn status 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "svn status 失败：$output"
        }

        $files = @()
        foreach ($line in $output) {
            if ($line -match '^\?\?\s+(.+)$') {
                $files += $Matches[1].Trim()
            }
            elseif ($line -match '^[MADRC!~]\s+(.+)$') {
                $files += $Matches[1].Trim()
            }
        }
        return ,$files
    }
    finally {
        Pop-Location
    }
}

function Test-ShouldSkipFile {
    param(
        [string]$FilePath,
        [object]$Config
    )

    if (-not (Test-Path -LiteralPath $FilePath)) {
        return $true
    }

    if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
        return $true
    }

    $ext = [System.IO.Path]::GetExtension($FilePath).ToLowerInvariant()
    foreach ($skip in $Config.skipExtensions) {
        if ($ext -eq $skip.ToLowerInvariant()) {
            return $true
        }
    }
    return $false
}

function Test-IsPropertyOnlyChange {
    param(
        [string[]]$Paths,
        [string]$Workspace
    )

    if (@($Paths).Count -eq 0) {
        return $false
    }

    $hasReviewableLeaf = $false
    foreach ($path in @($Paths)) {
        $fullPath = if ([System.IO.Path]::IsPathRooted($path)) { $path } else { Join-Path $Workspace $path }
        if ((Test-Path -LiteralPath $fullPath -PathType Leaf)) {
            $hasReviewableLeaf = $true
            break
        }
    }

    return -not $hasReviewableLeaf
}

function Get-CommitMessage {
    param(
        [string]$MessageFilePath,
        [string]$MessageTextValue
    )

    if ($MessageTextValue) {
        return $MessageTextValue.Trim()
    }
    if ($MessageFilePath -and (Test-Path $MessageFilePath)) {
        return (Get-Content $MessageFilePath -Raw -Encoding UTF8).Trim()
    }
    return ''
}

function Invoke-AgentReview {
    param(
        [string]$PluginRoot,
        [string]$Workspace,
        [string]$DiffPath,
        [string]$ReportPath,
        [string]$CommitMessage,
        [int]$TimeoutSeconds = 180
    )

    $prompt = @"
严格遵循 svn-code-review 技能（skills/svn-code-review/SKILL.md）中的审查规范与报告模板。
分析以下 diff 文件，将完整 Markdown 审查报告写入此路径：$ReportPath
不要修改任何源代码，只写报告文件。
若 diff 无实质文本变更，仍输出报告并结论为「通过」。

Diff 文件：$DiffPath
工作区：$Workspace
提交说明：$(if ($CommitMessage) { $CommitMessage } else { '（无）' })
"@

    $agentArgs = @(
        '-p', '--trust', '--mode', 'ask',
        '--plugin-dir', $PluginRoot,
        '--workspace', $Workspace,
        '--output-format', 'text',
        $prompt
    )

    $job = Start-Job -ScriptBlock {
        param($ArgsList)
        & agent @ArgsList 2>&1
    } -ArgumentList (,$agentArgs)

    $completed = Wait-Job -Job $job -Timeout $TimeoutSeconds
    if (-not $completed) {
        Stop-Job -Job $job -Force | Out-Null
        Remove-Job -Job $job -Force | Out-Null
        throw "agent 审查超时（${TimeoutSeconds}s）。请缩小提交范围或增大 agentTimeoutSeconds。"
    }

    $output = Receive-Job -Job $job
    $exitCode = 0
    if ($job.State -eq 'Failed') {
        $exitCode = 1
    }
    Remove-Job -Job $job -Force | Out-Null

    if ($exitCode -ne 0 -and -not (Test-Path $ReportPath)) {
        throw "agent 执行失败 (exit $exitCode)：$($output | Out-String)"
    }

    if (-not (Test-Path $ReportPath) -or (Get-Item $ReportPath).Length -eq 0) {
        $outputText = ($output | Out-String).Trim()
        if ($outputText) {
            Set-Content -Path $ReportPath -Value $outputText -Encoding UTF8
        }
    }

    if (-not (Test-Path $ReportPath)) {
        throw "AI 审查未生成报告。CLI 输出：$($output | Out-String)"
    }
}

function Get-ReportCounts {
    param(
        [string]$ReportPath,
        [object]$Config
    )

    $content = Get-Content $ReportPath -Raw -Encoding UTF8
    $criticalPattern = '(?m)^\s*-\s*' + [regex]::Escape($Config.criticalMarker)
    $warningPattern = '(?m)^\s*-\s*' + [regex]::Escape($Config.warningMarker)
    $suggestionPattern = '(?m)^\s*-\s*' + [regex]::Escape($Config.suggestionMarker)

    $critical = ([regex]::Matches($content, $criticalPattern)).Count
    $warning = ([regex]::Matches($content, $warningPattern)).Count
    $suggestion = ([regex]::Matches($content, $suggestionPattern)).Count

    if ($critical -eq 0 -and $content -match '\|\s*🔴\s*必须修复\s*\|\s*(\d+)\s*\|') {
        $parsed = [int]$Matches[1]
        if ($parsed -gt 0) { $critical = $parsed }
    }

    return @{
        Critical   = $critical
        Warning    = $warning
        Suggestion = $suggestion
        Content    = $content
    }
}

# --- Main ---

$workspace = (Resolve-Path $WorkspacePath).Path
$defaultConfigPath = Join-Path $scriptDir 'review-config.json'
$config = Get-ReviewConfig -Workspace $workspace -DefaultConfigPath $defaultConfigPath -OverrideConfigPath $ConfigPath

# 先判断是否需要审查，属性变更/无可审查文件时直接跳过（无需 agent）
$files = @($FileList | Where-Object { $_ -and $_.Trim() })
if (@($files).Count -eq 0) {
    $files = @(Get-SvnChangedFiles -Root $workspace)
}

$files = @(
    $files |
        ForEach-Object {
            if ([System.IO.Path]::IsPathRooted($_)) { $_ } else { Join-Path $workspace $_ }
        } |
        Where-Object { -not (Test-ShouldSkipFile -FilePath $_ -Config $config) } |
        Select-Object -Unique
)

if (@($files).Count -eq 0 -or (Test-IsPropertyOnlyChange -Paths @($FileList) -Workspace $workspace)) {
    if ($HookMode) { exit 0 }
    Write-Output @{ ExitCode = 0; Message = '无可审查的文本文件（可能为属性变更如 svn:ignore），已跳过。' }
    return
}

if (-not (Test-AgentCliAvailable)) {
    $msg = @"
Cursor CLI (agent) 未安装或未登录。
请执行：
  irm 'https://cursor.com/install?win32=true' | iex
  agent login
  agent status
"@
    if ($HookMode) {
        Write-ReviewError $msg
        exit 1
    }
    throw $msg
}

try {
    $pluginRoot = Get-TeamDeveloperAgentPluginRoot -ScriptRoot $scriptDir
}
catch {
    if ($HookMode) {
        Write-ReviewError $_.Exception.Message
        exit 1
    }
    throw
}

# 准备目录
$reviewRoot = Join-Path $workspace '.review'
$tempDir = Join-Path $reviewRoot 'temp'
$reportDir = Join-Path $reviewRoot 'reports'
New-Item -ItemType Directory -Force -Path $tempDir, $reportDir | Out-Null

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$diffPath = Join-Path $tempDir "review-$timestamp.diff"
$reportPath = Join-Path $reportDir "review-$timestamp.md"

Push-Location $workspace
try {
    $relativeFiles = @($files | ForEach-Object {
        if ($_.StartsWith($workspace, [StringComparison]::OrdinalIgnoreCase)) {
            $_.Substring($workspace.Length).TrimStart('\', '/')
        }
        else { $_ }
    })

    if (@($relativeFiles).Count -eq 0) {
        $diffText = ''
    }
    else {
        $diffOutput = & svn diff @relativeFiles 2>&1
        if ($LASTEXITCODE -ne 0) {
            $diffOutputText = ($diffOutput | Out-String).Trim()
            if ($diffOutputText -match '参数错误|parameter|E155010|E200009') {
                if ($HookMode) { exit 0 }
                Write-Output @{ ExitCode = 0; Message = 'svn diff 无文本变更（可能为属性变更），已跳过。' }
                return
            }
            throw "svn diff 失败：$diffOutputText"
        }
        $diffText = ($diffOutput | Out-String)
    }

    Set-Content -Path $diffPath -Value $diffText -Encoding UTF8
}
finally {
    Pop-Location
}

if ([string]::IsNullOrWhiteSpace($diffText)) {
    Set-Content -Path $reportPath -Value @"
# SVN 代码审查报告

- **时间**：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- **工作区**：$workspace

## 概要

无文本 diff（可能仅为属性变更或二进制文件），跳过 AI 深度审查。

## 结论

**通过**
"@ -Encoding UTF8

    if ($HookMode) { exit 0 }
    Write-Output @{ ExitCode = 0; ReportPath = $reportPath; Message = '无文本 diff，已跳过。' }
    return
}

$diffLineCount = ($diffText -split "`n").Count
if ($diffLineCount -gt $config.maxDiffLines) {
    Write-Host "Diff 行数 ($diffLineCount) 超过阈值 ($($config.maxDiffLines))，仍将提交审查但可能较慢。" -ForegroundColor Yellow
}

$commitMessage = Get-CommitMessage -MessageFilePath $MessageFile -MessageTextValue $MessageText

try {
    Invoke-AgentReview `
        -PluginRoot $pluginRoot `
        -Workspace $workspace `
        -DiffPath $diffPath `
        -ReportPath $reportPath `
        -CommitMessage $commitMessage `
        -TimeoutSeconds ([int]$config.agentTimeoutSeconds)
}
catch {
    if ($HookMode) {
        Write-ReviewError $_.Exception.Message
        exit 1
    }
    throw
}

$counts = Get-ReportCounts -ReportPath $reportPath -Config $config

Write-Host ""
Write-Host "审查完成：$reportPath" -ForegroundColor Green
Write-Host "🔴 $($counts.Critical)  🟡 $($counts.Warning)  🟢 $($counts.Suggestion)"

if ($config.openReportAfterReview) {
    Start-Process $reportPath
}

if ($HookMode) {
    $dialog = Show-SvnReviewDialog `
        -ReportPath $reportPath `
        -CriticalCount $counts.Critical `
        -WarningCount $counts.Warning `
        -SuggestionCount $counts.Suggestion `
        -GateMode $config.gateMode

    if ($dialog.AllowCommit) {
        exit 0
    }

    Write-ReviewError '已取消 SVN 提交。请查看审查报告并修复问题后重试。'
    exit 1
}

Write-Output @{
    ExitCode   = 0
    ReportPath = $reportPath
    Critical   = $counts.Critical
    Warning    = $counts.Warning
    Suggestion = $counts.Suggestion
}
