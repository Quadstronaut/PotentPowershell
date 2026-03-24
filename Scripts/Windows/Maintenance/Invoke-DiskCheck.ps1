<#
.SYNOPSIS
    Runs chkdsk on C: to check for and fix filesystem errors.

.DESCRIPTION
    Checks for administrator privileges (required by chkdsk /f).
    Re-launches as admin if needed, then runs chkdsk C: /f /r.
    /f fixes errors; /r locates bad sectors and recovers readable data.

.PARAMETER None
    No parameters. Auto-elevates if not already admin.

.EXAMPLE
    PS> .\Invoke-DiskCheck.ps1

.NOTES
    Author   : Quadstronaut
    Requires : Administrator privileges (auto-elevates)
    Note     : chkdsk /r on a live C: drive schedules the check for next reboot.
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

chkdsk C: /f /r
