#Requires -Version 5.1
<#
.SYNOPSIS
    One-click deploy SVN AI Review to local stable path (does not install Cursor plugin).
.PARAMETER WorkingCopyPath
    Tortoise Hook Working Copy Path. Default E:\project.
.PARAMETER Force
    Overwrite existing deploy dir. Default $true.
.PARAMETER SkipAgentCheck
    Skip Cursor CLI check.
.EXAMPLE
    .\Deploy-SvnAiReview.ps1
.EXAMPLE
    .\Deploy-SvnAiReview.ps1 -WorkingCopyPath "E:\project\02_Exoscope\Exoscope.Desktop-YG-Develop"
#>
[CmdletBinding()]
param(
    [string]$WorkingCopyPath = 'E:\project',
    [bool]$Force = $true,
    [switch]$SkipAgentCheck
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:RequiredFiles = @(
    'Invoke-SvnAiReview.ps1',
    'review-pre-commit.ps1',
    'Show-ReviewDialog.ps1',
    'Resolve-PluginRoot.ps1',
    'review-config.json'
)

function Test-SourceDirHealthy {
    param([Parameter(Mandatory = $true)][string]$Dir)

    foreach ($name in $script:RequiredFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $Dir $name))) {
            return $false
        }
    }

    $preCommit = Join-Path $Dir 'review-pre-commit.ps1'
    $raw = Get-Content -LiteralPath $preCommit -Raw -ErrorAction SilentlyContinue
    if ($raw -match '<<<<<<<') {
        return $false
    }

    return $true
}

function Find-SvnAiReviewSourceDirs {
    $roots = @(
        (Join-Path $env:USERPROFILE '.cursor\plugins\cache\team-plugins\team-developer-agent'),
        (Join-Path $env:USERPROFILE '.cursor\plugins\cache\team-plugins\hgteamcursorplugin')
    )

    $found = New-Object System.Collections.ArrayList

    foreach ($root in $roots) {
        if (-not (Test-Path -LiteralPath $root)) { continue }

        $files = @(Get-ChildItem -LiteralPath $root -Recurse -Filter 'Invoke-SvnAiReview.ps1' -ErrorAction SilentlyContinue)
        foreach ($file in $files) {
            $dir = [string]$file.DirectoryName
            if ($dir -notmatch '[\\/]svn-ai-review$') { continue }

            $item = New-Object psobject -Property @{
                Path     = $dir
                Healthy  = [bool](Test-SourceDirHealthy -Dir $dir)
                Modified = $file.LastWriteTimeUtc
            }
            [void]$found.Add($item)
        }
    }

    return $found.ToArray()
}

function Select-BestSourceDir {
    $candidates = @(Find-SvnAiReviewSourceDirs)
    if ($candidates.Count -eq 0) {
        throw 'team-developer-agent svn-ai-review scripts not found. Install the plugin in Cursor first.'
    }

    $healthy = @($candidates | Where-Object { $_.Healthy } | Sort-Object Modified -Descending)
    if ($healthy.Count -gt 0) {
        return ($healthy[0].Path)
    }

    $ordered = @($candidates | Sort-Object Modified -Descending)
    $fallbackPath = $ordered[0].Path
    Write-Host "[WARN] Source may contain conflict markers: $fallbackPath" -ForegroundColor Yellow
    Write-Host '       Update team-developer-agent plugin and re-run if Hook fails.' -ForegroundColor Yellow
    return $fallbackPath
}

function Test-AgentCli {
    $agent = Get-Command agent -ErrorAction SilentlyContinue
    if (-not $agent) {
        Write-Host '[WARN] Cursor CLI (agent) not found. Hook review requires CLI.' -ForegroundColor Yellow
        Write-Host "       Install: irm 'https://cursor.com/install?win32=true' | iex"
        Write-Host '       Login  : agent login'
        Write-Host '       Status : agent status'
        return $false
    }

    Write-Host "[OK] Cursor CLI: $($agent.Source)" -ForegroundColor Green
    try {
        $status = & agent status 2>&1 | Out-String
        if ($status -match '(?i)logged in|authenticated') {
            Write-Host '[OK] agent logged in' -ForegroundColor Green
        }
        else {
            Write-Host '[WARN] agent may not be logged in. Run: agent login' -ForegroundColor Yellow
            Write-Host ($status.Trim()) -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "[WARN] agent status failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    return $true
}

Write-Host '=== SVN AI Review one-click deploy ===' -ForegroundColor Cyan
Write-Host '(Does not install plugin. Tortoise Hook is local-only, not shared via SVN.)' -ForegroundColor DarkGray
Write-Host ''

$sourceDir = Select-BestSourceDir
Write-Host "[OK] Source: $sourceDir" -ForegroundColor Green

$targetDir = Join-Path $env:LOCALAPPDATA 'ExoscopeTeam\svn-ai-review'
if ((Test-Path -LiteralPath $targetDir) -and -not $Force) {
    Write-Host "[WARN] Target exists: $targetDir (pass -Force `$true to overwrite)" -ForegroundColor Yellow
}
else {
    if (Test-Path -LiteralPath $targetDir) {
        Remove-Item -LiteralPath $targetDir -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

    Get-ChildItem -LiteralPath $sourceDir -Force |
        Where-Object { $_.Name -notmatch '^\.git' } |
        ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $targetDir -Recurse -Force
        }

    $selfPath = $MyInvocation.MyCommand.Path
    if ($selfPath -and (Test-Path -LiteralPath $selfPath)) {
        Copy-Item -LiteralPath $selfPath -Destination (Join-Path $targetDir 'Deploy-SvnAiReview.ps1') -Force
    }

    Write-Host "[OK] Deployed: $targetDir" -ForegroundColor Green
}

$hookPs1 = Join-Path $targetDir 'review-pre-commit.ps1'
if (-not (Test-Path -LiteralPath $hookPs1)) {
    throw "Deploy incomplete. Missing: $hookPs1"
}

$preCommitRaw = Get-Content -LiteralPath $hookPs1 -Raw
if ($preCommitRaw -match '<<<<<<<') {
    throw 'Deployed review-pre-commit.ps1 still has git conflict markers. Update plugin and re-run.'
}

if (-not $SkipAgentCheck) {
    $null = Test-AgentCli
}

if (Test-Path -LiteralPath $WorkingCopyPath) {
    $wcPath = (Resolve-Path -LiteralPath $WorkingCopyPath).Path
}
else {
    Write-Host "[WARN] WorkingCopyPath not found, using literal: $WorkingCopyPath" -ForegroundColor Yellow
    $wcPath = $WorkingCopyPath
}

$cmdLine = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + $hookPs1 + '"'

Write-Host ''
Write-Host '=== Configure TortoiseSVN on THIS machine (each teammate configures locally) ===' -ForegroundColor Cyan
Write-Host ''
Write-Host 'TortoiseSVN -> Settings -> Hook Scripts -> Add'
Write-Host '  Hook Type         : Pre-commit'
Write-Host ('  Working Copy Path : ' + $wcPath)
Write-Host '  Command Line      : (copy the next line; do NOT append %PATH%)'
Write-Host ''
Write-Host $cmdLine -ForegroundColor White
Write-Host ''
Write-Host '  Wait for the script to finish : checked'
Write-Host '  Hide the script while running : optional'
Write-Host ''
Write-Host 'Notes:' -ForegroundColor Yellow
Write-Host '- User folder in Command Line comes from this PC LOCALAPPDATA; teammates differ (expected).'
Write-Host '- Hook lives in local Tortoise settings/registry; it is NOT committed to SVN.'
Write-Host '- Only TortoiseSVN -> Commit triggers the Hook (not VS / svn.exe).'
Write-Host ''
Write-Host '=== Manual review ===' -ForegroundColor Cyan
$manual = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + (Join-Path $targetDir 'Invoke-SvnAiReview.ps1') + '" -WorkspacePath "' + $wcPath + '"'
Write-Host $manual
Write-Host 'Or in Cursor: /team:svn-review'
Write-Host ''
Write-Host '=== Done ===' -ForegroundColor Green