<#
.SYNOPSIS
    Removes the Safe Mode boot flag so Windows boots normally on next restart.

.DESCRIPTION
    Deletes the bcdedit safeboot value from the current boot entry. Run this while
    in Safe Mode to return to normal boot, or run it before a restart if you set
    Safe Mode accidentally.

.PARAMETER None
    No parameters. Requires administrator privileges.

.EXAMPLE
    PS> .\Exit-SafeMode.ps1

.NOTES
    Author   : Quadstronaut
    Requires : Administrator privileges
    Note     : Does NOT reboot — restart manually when ready.
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'This script needs to be run as an administrator.'
    Exit
}

Write-Host "Removing Safe Mode boot flag..."
& bcdedit /deletevalue '{current}' safeboot

Write-Host "Done. Restart the computer to boot normally."
