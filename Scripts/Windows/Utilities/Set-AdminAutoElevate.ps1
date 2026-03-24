<#
.SYNOPSIS
    Configures PowerShell to always launch with administrator privileges.

.DESCRIPTION
    Sets the execution policy to Unrestricted for the current user, creates the
    PowerShell profile if it doesn't exist, and appends an auto-elevation snippet
    that re-launches new PowerShell windows as admin if they aren't already.

.PARAMETER None
    No parameters. Auto-elevates if not already admin.

.EXAMPLE
    PS> .\Set-AdminAutoElevate.ps1

.NOTES
    Author   : Quadstronaut
    Requires : Administrator privileges (auto-elevates)
    Warning  : Sets execution policy to Unrestricted for current user.
               Consider RemoteSigned as a safer alternative.
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Start-Process powershell.exe -Verb runAs "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force

$profilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$elevationSnippet = @'

# Auto-elevate: if this session is not admin, re-launch as admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb runAs
}
'@

Add-Content -Path $profilePath -Value $elevationSnippet

. $profilePath

Write-Host 'PowerShell windows will now start with administrative privileges.'
