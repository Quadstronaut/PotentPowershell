# Get a list of installed Python packages using Chocolatey
$pythonPackages = choco list python -lo | Select-String -Pattern '^python'

# Sort the packages by version number
$pythonPackages = $pythonPackages | Sort-Object -Descending { [version]($_ -split ' ')[-1] }

# Get the latest version of Python
$latestPythonVersion = $pythonPackages[0] -split ' ')[-1]

# Loop through the installed Python versions and upgrade/remove all but the latest
foreach ($package in $pythonPackages) {
    $version = ($package -split ' ')[-1]
    if ($version -ne $latestPythonVersion) {
        choco upgrade $package -y
        choco uninstall $package -y
    }
}

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