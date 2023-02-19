<#
.SYNOPSIS
  Runs chkdsk on the specified drive and displays the results.

.DESCRIPTION
  This script runs the chkdsk utility on the specified drive and displays the results. The script prompts the user to enter the drive letter to check and the parameters to use with chkdsk. The script then runs chkdsk with the specified parameters and displays the results.

.PARAMETER None
  This script does not take any parameters.

.EXAMPLE
  PS> .\chkdsk.ps1
  Runs chkdsk on the specified drive and displays the results.

.NOTES
  This script runs the chkdsk utility on the specified drive and displays the results. The script prompts the user to enter the drive letter to check and the parameters to use with chkdsk. The script then runs chkdsk with the specified parameters and displays the results. This script is for diagnostic purposes only and should be used with caution.
#>

# Check if the current user has administrative privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# If the current user is not an administrator, prompt for administrative privileges
if (-not $isAdmin) {
  Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
  exit
}

# Run chkdsk to check for and fix errors
chkdsk C: /f /r