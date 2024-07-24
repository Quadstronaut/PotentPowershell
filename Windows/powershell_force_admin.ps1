# Check if the script is being run with administrative privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# If not, re-run the script with elevated privileges
if (-not $isAdmin) {
  Start-Process powershell.exe -Verb runAs "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
  exit
}

# Set the execution policy to unrestricted
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force

# Add the PowerShell profile if it doesn't exist
$profilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
if (!(Test-Path $profilePath)) {
  New-Item -ItemType File -Path $profilePath
}

# Add the code to run PowerShell windows with administrative privileges to the profile
Add-Content -Path $profilePath -Value "`nif (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Start-Process powershell.exe -Verb runAs '-NoExit -Command `'$args`'' } else { Invoke-Expression $args }`n"

# Reload the PowerShell profile
. $profilePath

Write-Host 'PowerShell windows will now start with administrative privileges.'