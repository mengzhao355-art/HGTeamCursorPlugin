#Requires -Version 5.1
<#
.SYNOPSIS
    Resolve team-developer-agent plugin root directory.
#>
function Get-TeamDeveloperAgentPluginRoot {
    [CmdletBinding()]
    param(
        [string]$ScriptRoot = $PSScriptRoot
    )

    # 1) Script location: .../team-developer-agent/scripts/svn-ai-review
    $candidate = Split-Path (Split-Path $ScriptRoot -Parent) -Parent
    $manifest = Join-Path $candidate '.cursor-plugin\plugin.json'
    if (Test-Path $manifest) {
        $json = Get-Content $manifest -Raw | ConvertFrom-Json
        if ($json.name -eq 'team-developer-agent') {
            return (Resolve-Path $candidate).Path
        }
    }

    # 2) Cursor plugin cache: .../team-developer-agent/{hash}/
    $cacheBase = Join-Path $env:USERPROFILE '.cursor\plugins\cache\team-plugins\team-developer-agent'
    if (Test-Path $cacheBase) {
        $hashDirs = Get-ChildItem -Path $cacheBase -Directory -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending
        foreach ($hashDir in $hashDirs) {
            $manifestPath = Join-Path $hashDir.FullName '.cursor-plugin\plugin.json'
            if (Test-Path $manifestPath) {
                $json = Get-Content $manifestPath -Raw | ConvertFrom-Json
                if ($json.name -eq 'team-developer-agent') {
                    return (Resolve-Path $hashDir.FullName).Path
                }
            }
        }
    }

    throw 'team-developer-agent plugin not found. Install from Team Marketplace or run from HGTeamCursorPlugin repo.'
}

if ($MyInvocation.InvocationName -ne '.') {
    Get-TeamDeveloperAgentPluginRoot @PSBoundParameters
}
