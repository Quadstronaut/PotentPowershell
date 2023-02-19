# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'This script needs to be run as an administrator. Please run PowerShell as an administrator and try again.'
    Exit
}

# Set boot configuration to Safe Mode with Networking
$bcdedit = 'bcdedit.exe'
$params = '/set {current} safeboot network'
& $bcdedit $params

# Reboot the machine
Restart-Computer -Force