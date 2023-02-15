<#
.SYNOPSIS
  This script performs various system maintenance tasks, including running system file checker (SFC), the Deployment Image Servicing and Management (DISM) tool, and Windows Update. It also checks if Chocolatey is installed and upgrades all installed packages, and upgrades pip if it is installed.

.DESCRIPTION
  This script performs the following steps:
  1. Verifies that it is running in administrator mode.
  2. Checks if Chocolatey is installed and installs it if it is not.
  3. Runs the sfc /scannow and dism online repair restore commands in parallel and forks them to the background.
  4. Queries Chocolatey for installed packages and their versions, and saves the information to a text file.
  5. Upgrades all installed packages using Chocolatey.
  6. Checks if pip is installed and upgrades it if it is.
  7. Downloads and installs all available Windows updates but does not reboot.

.PARAMETER None
  This script does not take any parameters.

.EXAMPLE
  PS> .\upgrade.ps1
  Runs the system maintenance tasks.

.NOTES
  This script requires PowerShell version 5.1 or higher.
#>

# Check if the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'This script must be run with administrative privileges.'
    Exit 1
}
  
# Check if Chocolatey is installed and install it if it is not
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host 'Chocolatey is not installed. Attempting to install Chocolatey...'
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
  
# Run SFC and DISM commands in parallel and fork them to the background
Start-Process -FilePath 'powershell.exe' -ArgumentList '-Command sfc /scannow' -Verb RunAs -WindowStyle Hidden
Start-Process -FilePath 'powershell.exe' -ArgumentList '-Command dism /Online /Cleanup-Image /RestoreHealth' -Verb RunAs -WindowStyle Hidden
  
# Query Chocolatey for installed packages and versions
if (Get-Command choco -ErrorAction SilentlyContinue) {
    $chocoInfo = choco list --local-only
    $chocoInfo | Out-File "$HOME\Documents\Chocolatey.txt"
}
  
# Upgrade all installed packages using Chocolatey
choco upgrade all -y
  
# Check if pip is installed and upgrade it if it is
if (Get-Command pip -ErrorAction SilentlyContinue) {
    Write-Host 'Upgrading pip...'
    pip install --upgrade pip
}
  
# Download and install all available Windows updates but do not reboot
Write-Host 'Downloading and installing Windows updates...'
$session = New-Object -ComObject Microsoft.Update.Session
$updater = $session.CreateUpdateInstaller()
$updates = $session.CreateUpdateSearcher().Search('IsInstalled=0')
$updates | ForEach-Object {
    $updater.AddUpdate($_)
}
$result = $updater.Install()
if ($result.ResultCode -eq 2) {
    Write-Host 'There are no updates available.'
}
elseif ($result.ResultCode -eq 3) {
    Write-Host 'Updates were downloaded and installed successfully.'
    Write-Host 'A reboot may be required, but one has not been forced.'