# Set time range (7 days)
$StartTime = (Get-Date).AddDays(-7)
$EndTime = Get-Date

# Get error events (Level 2)
$Events = Get-WinEvent -FilterHashtable @{
    LogName = 'Application', 'System'
    Level = 2 
    StartTime = $StartTime
    EndTime = $EndTime 
}

# Group events by source and count
$EventGroups = $Events | Group-Object Source

# Error threshold (adjust as needed)
$ErrorThreshold = 10

# Process each source group
foreach ($Group in $EventGroups) {
    $EventCount = $Group.Count

    # Check if error count exceeds threshold
    if ($EventCount -gt $ErrorThreshold) {
        Write-Warning "The source '$($Group.Name)' generated $($EventCount) errors in the past 7 days:"

        # Display summary of error events
        $Group.Group | Select-Object -First 10 | Format-Table -AutoSize | Out-String | Write-Host
    }
}

if (-not $EventGroups) { 
    Write-Host "No errors found in the Application or System logs within the past 7 days."
}
