# Check if the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host 'This script must be run with administrative privileges.'
  Exit 1
}
  
# Define the list of directories to search for installed software
$directories = @('C:\Program Files\', 'C:\Program Files (x86)\')
  
# Initialize the list of matching software
$matchingSoftware = @()
  
# Loop through the directories and search for executable files
foreach ($directory in $directories) {
  $exeFiles = Get-ChildItem -Path $directory -Filter *.exe -Recurse -ErrorAction SilentlyContinue
  foreach ($exeFile in $exeFiles) {
    # If the executable file matches a package in the Chocolatey repository, add it to the list of matching software
    $packageName = Find-Package $exeFile.Name -Provider chocolatey -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
    if ($packageName) {
      $matchingSoftware += $packageName
    }
  }
}
  
# If matching software was found, install Chocolatey (if it is not already installed) and configure it to be able to upgrade the software
if ($matchingSoftware) {
  # Check if Chocolatey is installed and install it if it is not
  if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host 'Chocolatey is not installed. Attempting to install Chocolatey...'
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  }
  
  # Configure Chocolatey to upgrade software
  Write-Host 'Configuring Chocolatey...'
  $matchingSoftware | ForEach-Object { choco pin add -n=$_ }
  
  # Upgrade software using Chocolatey
  Write-Host 'Upgrading software using Chocolatey...'
  choco upgrade $matchingSoftware -y
}
else {
  Write-Host 'No matching software was found.'
}