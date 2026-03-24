<#
.SYNOPSIS
    Finds software already installed on the system that has a Chocolatey package, then manages it via Chocolatey.

.DESCRIPTION
    Scans Program Files directories for installed executables, queries the Chocolatey
    repository for matching packages, installs Chocolatey if needed, pins the found
    packages for tracking, and upgrades them.

    Useful for "late adoption" — you already have software installed manually and want
    to bring it under Chocolatey management without reinstalling.

.PARAMETER None
    No parameters. Requires administrator privileges.

.EXAMPLE
    PS> .\Import-ChocolateyPackages.ps1

.NOTES
    Author   : Quadstronaut
    Requires : Administrator privileges, internet access
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'This script must be run with administrative privileges.'
    Exit 1
}

$directories      = @('C:\Program Files\', 'C:\Program Files (x86)\')
$matchingSoftware = @()

foreach ($directory in $directories) {
    $exeFiles = Get-ChildItem -Path $directory -Filter *.exe -Recurse -ErrorAction SilentlyContinue
    foreach ($exeFile in $exeFiles) {
        $packageName = Find-Package $exeFile.Name -Provider chocolatey -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty Name
        if ($packageName) {
            $matchingSoftware += $packageName
        }
    }
}

if ($matchingSoftware) {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host 'Installing Chocolatey...'
        Set-ExecutionPolicy Bypass -Scope Process -Force
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }

    Write-Host "Found $($matchingSoftware.Count) matching packages. Pinning and upgrading..."
    $matchingSoftware | ForEach-Object { choco pin add -n=$_ }
    choco upgrade $matchingSoftware -y
}
else {
    Write-Host 'No matching software found in Program Files directories.'
}
