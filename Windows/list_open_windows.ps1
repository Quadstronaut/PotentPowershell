# --- LIST OPEN WINDOWS ---

<#
.SYNOPSIS
    Lists the process name and main window title for all open applications.
.DESCRIPTION
    This script iterates through all processes on the system that have a main window
    associated with them. It is designed to help users identify the correct
    MainWindowTitle for use in automation and scripting tasks.
#>

# Start by providing a clear header for the output.
Write-Host "--- Active Window Titles ---"
Write-Host "ProcessName`t`tMainWindowTitle"
Write-Host "--------------------------------------------------------"

# Use Get-Process to retrieve all processes.
# The 'Where-Object' clause filters for processes that actually have a main window title.
# This avoids listing background services or other processes without a GUI.
$processesWithWindows = Get-Process | Where-Object { -not [string]::IsNullOrEmpty($_.MainWindowTitle) }

# Loop through each process found.
foreach ($process in $processesWithWindows) {
    # Output the process name and its main window title.
    # We use a tab (`t`) for clear column separation.
    Write-Host "$($process.ProcessName)`t`t$($process.MainWindowTitle)"
}

Write-Host "--------------------------------------------------------"
Write-Host "End of list. Use the 'MainWindowTitle' from this list to match your windows."
