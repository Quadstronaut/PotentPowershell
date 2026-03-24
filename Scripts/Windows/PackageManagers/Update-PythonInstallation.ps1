<#
.SYNOPSIS
    Upgrades all Python installations to the latest version and optionally removes virtual environments.

.DESCRIPTION
    Detects installed Python versions via Chocolatey or registry. Upgrades older
    versions and removes them, keeping only the latest. Upgrades pip. Optionally
    deletes all virtualenv environments found in the user's Envs directory.

.PARAMETER None
    No parameters. Requires administrator privileges.

.EXAMPLE
    PS> .\Update-PythonInstallation.ps1

.NOTES
    Author   : Quadstronaut
    Requires : Administrator privileges, Chocolatey (preferred) or manual Python installs
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'This script requires administrative privileges.'
    Exit
}

# Install Chocolatey if missing
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host 'Installing Chocolatey...'
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Detect installed Python versions
if (Get-Command choco -ErrorAction SilentlyContinue) {
    $pythonPackages = choco list python -lo | Select-String -Pattern '^python'
    $pythonPackages = $pythonPackages | Sort-Object -Descending { [version]($_ -split ' ')[-1] }
}
else {
    Write-Host 'Detecting Python versions manually from registry...'
    $pythonPath     = Get-ItemProperty -Path 'HKLM:\Software\Python\PythonCore\*' -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty '(default)'
    $pythonPackages = Get-ChildItem -Path $pythonPath -Directory |
        Select-Object -ExpandProperty Name |
        Where-Object { $_ -like 'Python*' }
}

if (-not $pythonPackages) {
    Write-Host 'No Python installations found.'
    return
}

$latestPythonVersion = ($pythonPackages[0] -split ' ')[-1]
Write-Host "Latest Python version detected: $latestPythonVersion"

foreach ($package in $pythonPackages) {
    $version = ($package -split ' ')[-1]
    if ($version -ne $latestPythonVersion) {
        Write-Host "Upgrading/removing $package..."
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            choco upgrade $package -y
            choco uninstall $package -y
        }
        else {
            $uninstallPath = Join-Path -Path $pythonPath -ChildPath $package
            Start-Process -FilePath "$uninstallPath\unins000.exe" -ArgumentList '/uninstall /quiet' -Wait
            Remove-Item -Path $uninstallPath -Recurse -Force
        }
    }
}

# Upgrade pip
Write-Host 'Upgrading pip...'
python -m pip install --upgrade pip

# Optionally remove virtual environments
$virtualEnvironments = Get-ChildItem "$env:USERPROFILE\Envs" -Directory -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty FullName

if ($virtualEnvironments.Count -gt 0) {
    $confirm = Read-Host "Delete $($virtualEnvironments.Count) virtual environment(s)? (y/n)"
    if ($confirm -eq 'y') {
        Remove-Item $virtualEnvironments -Recurse -Force
        Write-Host 'Virtual environments deleted.'
    }
}
else {
    Write-Host 'No virtual environments found.'
}
