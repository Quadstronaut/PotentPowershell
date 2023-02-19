<#
.SYNOPSIS
  Evaluates the Windows event logs for errors over the past 7 days.

.DESCRIPTION
  This script evaluates the Windows event logs for errors over the past 7 days. The script searches for error events in the Application and System logs, and displays a report of any errors found. The report includes the event ID, source, and message for each error event.

.PARAMETER None
  This script does not take any parameters.

.EXAMPLE
  PS> .\7dayerroreval.ps1
  Evaluates the Windows event logs for errors over the past 7 days.

.NOTES
  This script evaluates the Windows event logs for errors over the past 7 days. The script searches for error events in the Application and System logs. If any errors are found, the script displays a report of the error events, including the event ID, source, and message. This script is for informational purposes only and should not be used to diagnose or fix issues.
#>

# Set the time range to search for logs
$StartTime = (Get-Date).AddDays(-7)
$EndTime = Get-Date

# Search for error events in the Windows event logs
$Events = Get-WinEvent -FilterHashtable @{LogName = 'Application', 'System'; Level = 2; StartTime = $StartTime; EndTime = $EndTime }

# Group the events by source and count the occurrences
$EventGroups = $Events | Group-Object -Property Source

# Loop through each event source
foreach ($Group in $EventGroups) {
  # Count the number of events in this group
  $EventCount = $Group.Count
    
  # If there are more than 10 events in this group, it may be considered an unusual problem
  if ($EventCount -gt 10) {
    Write-Host "The following events from source $($Group.Name) occurred $($EventCount) times in the past 7 days:"
    # Display the 10 most recent events from this group
    $Group.Group | Select-Object -First 10 | Format-List | Out-String | Write-Host
  }
}
