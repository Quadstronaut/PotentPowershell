# Check if the script is running in administrative mode
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'This script requires administrative privileges. Please run the script as an administrator and try again.'
    Exit
}

# Check if Chocolatey is installed, and install it if it is not
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host 'Chocolatey is not installed. Attempting to install Chocolatey...'
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Get a list of installed Python packages using Chocolatey, if available
if (Get-Command choco -ErrorAction SilentlyContinue) {
    $pythonPackages = choco list python -lo | Select-String -Pattern '^python'
    $pythonPackages = $pythonPackages | Sort-Object -Descending { [version]($_ -split ' ')[-1] }
}
else {
    Write-Host 'Chocolatey is not available. Attempting to detect installed Python versions manually...'
    $pythonPath = Get-ItemProperty -Path 'HKLM:\Software\Python\PythonCore\*' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty '(default)'
    $pythonPackages = Get-ChildItem -Path $pythonPath -Directory | Select-Object -ExpandProperty Name | Where-Object { $_ -like 'Python*' }
}

# Get the latest version of Python
$latestPythonVersion = $pythonPackages[0] -split ' ')[-1]

# Loop through the installed Python versions and upgrade/remove all but the latest
foreach ($package in $pythonPackages) {
    $version = ($package -split ' ')[-1]
    if ($version -ne $latestPythonVersion) {
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            choco upgrade $package -y
            choco uninstall $package -y
        }
        else {
            $uninstallPath = Join-Path -Path $pythonPath -ChildPath $package
            $uninstallArguments = '/uninstall /quiet'
            Start-Process -FilePath "$uninstallPath\unins000.exe" -ArgumentList $uninstallArguments -Wait
            Remove-Item -Path $uninstallPath -Recurse -Force
        }
    }
}

# Upgrade pip
python -m pip install --upgrade pip

# Prompt the user before deleting virtual environments
$virtualEnvironments = Get-ChildItem $env:USERPROFILE\Envs -Directory | Select-Object -ExpandProperty FullName
if ($virtualEnvironments.Count -gt 0) {
    $confirm = Read-Host "Are you sure you want to delete $($virtualEnvironments.Count) virtual environments? (y/n)"
    if ($confirm -eq 'y') {
        Remove-Item $virtualEnvironments -Recurse -Force
        Write-Host 'Virtual environments deleted.'
    }
}
else {
    Write-Host 'No virtual environments found.'
}