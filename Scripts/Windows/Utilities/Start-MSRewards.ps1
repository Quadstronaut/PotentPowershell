<#
.SYNOPSIS
    Opens Microsoft Edge to a search clicker page for Microsoft Rewards.

.DESCRIPTION
    Launches Microsoft Edge with the MS Edge Search Clicker page, waits 2 minutes
    for search credits to accumulate, then closes Edge.

    Intended for automated daily search point collection on Microsoft Rewards.

.PARAMETER WaitSeconds
    How long to keep Edge open before closing it. Default: 120 seconds.

.EXAMPLE
    PS> .\Start-MSRewards.ps1
    PS> .\Start-MSRewards.ps1 -WaitSeconds 180

.NOTES
    Author   : Quadstronaut
    Requires : Microsoft Edge installed at the default path
    Note     : The search clicker URL is a third-party tool. Verify it still works
               and complies with Microsoft Rewards terms of service before using.
#>

[CmdletBinding()]
param(
    [int]$WaitSeconds = 120
)

$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$url      = 'https://greybax.github.io/MSEdgeSearchClicker'

if (-not (Test-Path $edgePath)) {
    Write-Warning "Edge not found at: $edgePath"
    Write-Warning "Update the `$edgePath variable if Edge is installed elsewhere."
    exit 1
}

try {
    Write-Host "Opening Edge for $WaitSeconds seconds..."
    Start-Process -FilePath $edgePath -ArgumentList $url -ErrorAction Stop
    Start-Sleep -Seconds $WaitSeconds
    Stop-Process -Name 'msedge' -ErrorAction Stop
    Write-Host "Done."
}
catch {
    Write-Warning "Error: $($_.Exception.Message)"
    Exit 1
}
