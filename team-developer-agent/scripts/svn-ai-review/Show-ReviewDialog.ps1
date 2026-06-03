#Requires -Version 5.1
<#
.SYNOPSIS
    展示 SVN AI 审查结果确认对话框。
.PARAMETER ReportPath
    完整 Markdown 报告路径。
.PARAMETER CriticalCount
    必须修复项数量。
.PARAMETER WarningCount
    建议修复项数量。
.PARAMETER SuggestionCount
    优化建议数量。
.PARAMETER GateMode
    advisory | block_critical | block_all_issues
.OUTPUTS
    Hashtable: AllowCommit, ForceOverride
#>
function Show-SvnReviewDialog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ReportPath,

        [int]$CriticalCount = 0,
        [int]$WarningCount = 0,
        [int]$SuggestionCount = 0,

        [ValidateSet('advisory', 'block_critical', 'block_all_issues')]
        [string]$GateMode = 'advisory'
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $summary = @"
SVN 提交前 AI 代码审查完成

🔴 必须修复：$CriticalCount
🟡 建议修复：$WarningCount
🟢 优化建议：$SuggestionCount

报告：$ReportPath
"@

    $defaultBlock = $false
    switch ($GateMode) {
        'block_critical' { if ($CriticalCount -gt 0) { $defaultBlock = $true } }
        'block_all_issues' { if (($CriticalCount + $WarningCount + $SuggestionCount) -gt 0) { $defaultBlock = $true } }
    }

    if ($defaultBlock) {
        $message = $summary + "`n`n检测到需关注的问题。是否仍要继续提交？"
        $result = [System.Windows.Forms.MessageBox]::Show(
            $message,
            'SVN AI 代码审查',
            [System.Windows.Forms.MessageBoxButtons]::YesNoCancel,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )

        switch ($result) {
            'Yes' { return @{ AllowCommit = $true; ForceOverride = $true } }
            'No'  { return @{ AllowCommit = $false; ForceOverride = $false } }
            default { return @{ AllowCommit = $false; ForceOverride = $false } }
        }
    }

    $message = $summary + "`n`n是否继续 SVN 提交？"
    $result = [System.Windows.Forms.MessageBox]::Show(
        $message,
        'SVN AI 代码审查',
        [System.Windows.Forms.MessageBoxButtons]::YesNoCancel,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )

    switch ($result) {
        'Yes' { return @{ AllowCommit = $true; ForceOverride = $false } }
        default { return @{ AllowCommit = $false; ForceOverride = $false } }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Show-SvnReviewDialog @PSBoundParameters
}
