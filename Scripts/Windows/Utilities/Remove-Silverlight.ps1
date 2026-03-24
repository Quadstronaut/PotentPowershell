<#
.SYNOPSIS
    Completely removes Microsoft Silverlight from the system.

.DESCRIPTION
    Finds the Silverlight configuration executable, runs the silent uninstaller,
    removes registry entries, and deletes remaining Silverlight files from disk
    and the AppData browser plugin folder.

    Silverlight reached end-of-life in October 2021. No modern browser supports it.
    Removing it reduces attack surface.

.PARAMETER None
    No parameters.

.EXAMPLE
    PS> .\Remove-Silverlight.ps1

.NOTES
    Author   : Quadstronaut
    Requires : Administrator privileges recommended for registry and Program Files access
#>

$silverlightUninstallCommand = (
    Get-ChildItem -Path 'C:\Program Files (x86)\Microsoft Silverlight\*\Silverlight.Configuration.exe' -ErrorAction SilentlyContinue |
    Select-Object -Last 1
).FullName

if ($silverlightUninstallCommand) {
    Write-Host "Found Silverlight. Running silent uninstaller..."
    Start-Process -FilePath $silverlightUninstallCommand -ArgumentList '/uninstall /force /silent' -Wait

    Write-Host "Removing registry entries..."
    Remove-Item 'HKLM:\Software\Microsoft\Silverlight' -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{89F4137D-6C26-4A84-BDB8-2E5A4BB71E00}' -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "Removing Silverlight files..."
    Remove-Item 'C:\Program Files (x86)\Microsoft Silverlight' -Recurse -Force -ErrorAction SilentlyContinue

    $slPluginPath = Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)) 'Microsoft\Plugins'
    Remove-Item $slPluginPath -Recurse -Force -ErrorAction SilentlyContinue

    Write-Output 'Silverlight has been uninstalled.'
}
else {
    Write-Output 'Silverlight is not installed on this machine.'
}
