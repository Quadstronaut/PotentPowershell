# Get user input for the search string
$searchString = 'Elite'

while ($true) {
    # Get all running processes and filter them based on the search string
    # The `-ErrorAction SilentlyContinue` is used to suppress errors for processes
    # where the MainWindowTitle or Path is inaccessible.
    $processes = Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessName -like "*$searchString*" -or $_.MainWindowTitle -like "*$searchString*"
    }

    # If any processes are found, display them in a table
    if ($processes) {
        # Use Select-Object to get the desired properties and format the output as a table
        $processes | Select-Object Id, ProcessName, MainWindowTitle, Path | Format-Table -AutoSize
    }
    Start-Sleep -seconds 1
    Clear-Host
}