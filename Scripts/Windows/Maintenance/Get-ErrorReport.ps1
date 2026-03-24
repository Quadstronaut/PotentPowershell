<#
.SYNOPSIS
    Reports Application and System event log errors from the past 7 days.

.DESCRIPTION
    Queries the Application and System Windows Event Logs for Level 2 (Error) events
    in the last 7 days. Groups by source and highlights sources that exceed a
    configurable error threshold, showing the first 10 events from each noisy source.

.PARAMETER ErrorThreshold
    Number of errors from a single source that triggers a warning. Default: 10.

.PARAMETER DaysBack
    How many days back to look. Default: 7.

.EXAMPLE
    PS> .\Get-ErrorReport.ps1
    Reports sources with more than 10 errors in the past 7 days.

.EXAMPLE
    PS> .\Get-ErrorReport.ps1 -ErrorThreshold 5 -DaysBack 14

.NOTES
    Author   : Quadstronaut
    Requires : Read access to Windows Event Logs (admin recommended)
#>

[CmdletBinding()]
param(
    [int]$ErrorThreshold = 10,
    [int]$DaysBack = 7
)

$StartTime = (Get-Date).AddDays(-$DaysBack)
$EndTime   = Get-Date

Write-Verbose "Querying event logs from $StartTime to $EndTime..."

$Events = Get-WinEvent -FilterHashtable @{
    LogName   = 'Application', 'System'
    Level     = 2   # Error
    StartTime = $StartTime
    EndTime   = $EndTime
} -ErrorAction SilentlyContinue

if (-not $Events) {
    Write-Host "No errors found in the Application or System logs within the past $DaysBack days."
    return
}

$EventGroups = $Events | Group-Object Source

foreach ($Group in $EventGroups) {
    if ($Group.Count -gt $ErrorThreshold) {
        Write-Warning "Source '$($Group.Name)' generated $($Group.Count) errors in the past $DaysBack days:"
        $Group.Group | Select-Object -First 10 | Format-Table TimeCreated, Id, Message -AutoSize | Out-String | Write-Host
    }
}

Write-Host "Scan complete. $($Events.Count) total errors found across $($EventGroups.Count) sources."
