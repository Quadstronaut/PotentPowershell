<#
.SYNOPSIS
    Configures Windows to boot into Safe Mode with Networking on next restart.

.DESCRIPTION
    Uses bcdedit to set the safeboot flag to 'network', then restarts the computer.
    Safe Mode with Networking loads a minimal driver set plus network drivers,
    which is useful for malware removal, driver troubleshooting, and remote diagnostics.

.PARAMETER None
    No parameters. Requires administrator privileges. WILL REBOOT THE MACHINE.

.EXAMPLE
    PS> .\Enter-SafeMode.ps1

.NOTES
    Author   : Quadstronaut
    Requires : Administrator privileges
    WARNING  : This script will restart the computer immediately.
               To undo without rebooting, run Exit-SafeMode.ps1 first.
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'This script needs to be run as an administrator.'
    Exit
}

Write-Host "Setting boot configuration to Safe Mode with Networking..."
& bcdedit.exe /set '{current}' safeboot network

Write-Host "Restarting computer..."
Restart-Computer -Force
