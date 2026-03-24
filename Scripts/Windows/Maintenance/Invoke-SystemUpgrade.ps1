<#
.SYNOPSIS
    Performs comprehensive system maintenance: SFC, DISM, Chocolatey upgrades, pip, Windows Update.

.DESCRIPTION
    Runs the following steps in order:
      1. Verifies administrator privileges.
      2. Installs Chocolatey if missing.
      3. Runs sfc /scannow and DISM RestoreHealth in background processes.
      4. Saves a local Chocolatey package list to ~/Documents/Chocolatey.txt.
      5. Upgrades all Chocolatey packages.
      6. Upgrades pip if installed.
      7. Downloads and installs available Windows Updates (no forced reboot).

.PARAMETER None
    No parameters. Requires administrator privileges.

.EXAMPLE
    PS> .\Invoke-SystemUpgrade.ps1

.NOTES
    Author   : Quadstronaut
    Requires : PowerShell 5.1+, administrator privileges
#>

# Require admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'This script must be run with administrative privileges.'
    Exit 1
}

# Install Chocolatey if missing
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host 'Chocolatey not found. Installing...'
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Run SFC and DISM in background (they take a while; let them run in parallel)
Start-Process -FilePath 'powershell.exe' -ArgumentList '-Command sfc /scannow' -Verb RunAs -WindowStyle Hidden
Start-Process -FilePath 'powershell.exe' -ArgumentList '-Command dism /Online /Cleanup-Image /RestoreHealth' -Verb RunAs -WindowStyle Hidden

# Save Chocolatey package inventory
if (Get-Command choco -ErrorAction SilentlyContinue) {
    choco list --local-only | Out-File "$HOME\Documents\Chocolatey.txt"
    Write-Host "Chocolatey package list saved to $HOME\Documents\Chocolatey.txt"
}

# Upgrade all Chocolatey packages
Write-Host 'Upgrading Chocolatey packages...'
choco upgrade all -y

# Upgrade pip if installed
if (Get-Command pip -ErrorAction SilentlyContinue) {
    Write-Host 'Upgrading pip...'
    pip install --upgrade pip
}

# Install available Windows Updates (no reboot)
Write-Host 'Checking for Windows Updates...'
$session  = New-Object -ComObject Microsoft.Update.Session
$updater  = $session.CreateUpdateInstaller()
$search   = $session.CreateUpdateSearcher().Search('IsInstalled=0')
$updates  = $search.Updates

if ($updates.Count -eq 0) {
    Write-Host 'No updates available.'
}
else {
    $updater.Updates = $updates
    $result = $updater.Install()
    switch ($result.ResultCode) {
        2 { Write-Host 'No updates were installed.' }
        3 { Write-Host "Updates installed. A reboot may be required (not forced)." }
        default { Write-Host "Update result code: $($result.ResultCode)" }
    }
}

Write-Host 'System upgrade complete.'
