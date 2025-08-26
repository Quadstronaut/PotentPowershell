# --- GET SCREEN GEOMETRY ---

<#
.SYNOPSIS
    Outputs the geometry (bounds and working area) for all connected displays.
.DESCRIPTION
    This script uses the .NET framework's System.Windows.Forms.Screen class to
    gather information about each monitor connected to the system. It is useful
    for debugging window positioning scripts.
#>

# Add the necessary .NET assembly to access screen information.
Add-Type -AssemblyName System.Windows.Forms

# Get an array of all connected screens.
$allScreens = [System.Windows.Forms.Screen]::AllScreens

# Loop through each screen and display its properties.
Write-Host "--- Your Screen Geometry ---"
$i = 1
foreach ($screen in $allScreens) {
    Write-Host ""
    Write-Host "Screen #$i" -ForegroundColor Cyan
    Write-Host "--------------------"
    
    # Check if this is the primary monitor.
    if ($screen.Primary) {
        Write-Host "Primary Display: True"
    } else {
        Write-Host "Primary Display: False"
    }

    # Display the full bounds (including taskbar). This is what you'll use for positioning windows.
    Write-Host "Bounds (X, Y, Width, Height): $($screen.Bounds.X), $($screen.Bounds.Y), $($screen.Bounds.Width), $($screen.Bounds.Height)" -ForegroundColor Green

    # Display the working area (area without the taskbar).
    Write-Host "Working Area (X, Y, Width, Height): $($screen.WorkingArea.X), $($screen.WorkingArea.Y), $($screen.WorkingArea.Width), $($screen.WorkingArea.Height)"

    Write-Host "Device Name: $($screen.DeviceName)"
    $i++
}

Write-Host ""
Write-Host "--------------------"
Write-Host "End of report."
