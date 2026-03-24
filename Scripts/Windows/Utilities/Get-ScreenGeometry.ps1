<#
.SYNOPSIS
    Reports the bounds and working area for all connected displays.

.DESCRIPTION
    Uses System.Windows.Forms.Screen to enumerate all monitors and display their
    full bounds (including taskbar) and working area (excluding taskbar).

    Use the Bounds values when positioning windows programmatically — the working
    area excludes the taskbar but Bounds gives you the raw screen rectangle.

.PARAMETER None
    No parameters.

.EXAMPLE
    PS> .\Get-ScreenGeometry.ps1
    Screen #1 (Primary): Bounds 0,0,1920,1080 | WorkingArea 0,0,1920,1032

.NOTES
    Author : Quadstronaut
#>

Add-Type -AssemblyName System.Windows.Forms

$allScreens = [System.Windows.Forms.Screen]::AllScreens

Write-Host "--- Your Screen Geometry ---"
$i = 1
foreach ($screen in $allScreens) {
    Write-Host ""
    Write-Host "Screen #$i" -ForegroundColor Cyan
    Write-Host "  Primary      : $($screen.Primary)"
    Write-Host "  Bounds       : X=$($screen.Bounds.X), Y=$($screen.Bounds.Y), W=$($screen.Bounds.Width), H=$($screen.Bounds.Height)" -ForegroundColor Green
    Write-Host "  Working Area : X=$($screen.WorkingArea.X), Y=$($screen.WorkingArea.Y), W=$($screen.WorkingArea.Width), H=$($screen.WorkingArea.Height)"
    Write-Host "  Device Name  : $($screen.DeviceName)"
    $i++
}

Write-Host ""
Write-Host "Use Bounds for full-screen window positioning; WorkingArea excludes the taskbar."
