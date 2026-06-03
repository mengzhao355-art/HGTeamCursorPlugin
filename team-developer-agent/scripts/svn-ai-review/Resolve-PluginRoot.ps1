#Requires -Version 5.1
<#
.SYNOPSIS
    Resolve team-developer-agent plugin root directory.
#>
Set-StrictMode -Version Latest

function Read-JsonFileUtf8 {
    param([Parameter(Mandatory = $true)][string]$Path)

    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    $content = [System.IO.File]::ReadAllText($Path, $utf8NoBom)
    if ($content.Length -gt 0 -and [int][char]$content[0] -eq 0xFEFF) {
        $content = $content.Substring(1)
    }
    return $content | ConvertFrom-Json
}

function Test-TeamDeveloperAgentRoot {
    param([Parameter(Mandatory = $true)][string]$CandidatePath)

    $manifest = Join-Path $CandidatePath '.cursor-plugin\plugin.json'
    if (-not (Test-Path -LiteralPath $manifest)) {
        return $false
    }

    try {
        $json = Read-JsonFileUtf8 -Path $manifest
        return ($json.name -eq 'team-developer-agent')
    }
    catch {
        $raw = [System.IO.File]::ReadAllText($manifest, (New-Object System.Text.UTF8Encoding $false))
        return ($raw -match '"name"\s*:\s*"team-developer-agent"')
    }
}

function Get-TeamDeveloperAgentPluginRoot {
    [CmdletBinding()]
    param(
        [string]$ScriptRoot = $PSScriptRoot
    )

    $candidates = @()

    $fromScript = Split-Path (Split-Path $ScriptRoot -Parent) -Parent
    if (Test-TeamDeveloperAgentRoot -CandidatePath $fromScript) {
        $candidates += (Resolve-Path -LiteralPath $fromScript).Path
    }

    $cacheBase = Join-Path $env:USERPROFILE '.cursor\plugins\cache\team-plugins\team-developer-agent'
    if (Test-Path -LiteralPath $cacheBase) {
        $hashDirs = Get-ChildItem -LiteralPath $cacheBase -Directory -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending
        foreach ($hashDir in $hashDirs) {
            if (Test-TeamDeveloperAgentRoot -CandidatePath $hashDir.FullName) {
                $candidates += (Resolve-Path -LiteralPath $hashDir.FullName).Path
            }
        }
    }

    $hgPlugin = Join-Path $env:USERPROFILE '.cursor\plugins\cache\team-plugins\hgteamcursorplugin'
    $devAgent = Join-Path $hgPlugin 'team-developer-agent'
    if (Test-Path -LiteralPath $devAgent) {
        if (Test-TeamDeveloperAgentRoot -CandidatePath $devAgent) {
            $candidates += (Resolve-Path -LiteralPath $devAgent).Path
        }
    }

    if ($candidates.Count -eq 0) {
        throw '未找到 team-developer-agent 插件。请在 Cursor Team Marketplace 安装或更新插件。'
    }

    return ($candidates | Select-Object -Unique | Select-Object -First 1)
}

if ($MyInvocation.InvocationName -ne '.') {
    Get-TeamDeveloperAgentPluginRoot @PSBoundParameters
}
