<#
.SYNOPSIS
  Forces Steam to verify all files for the base installation and all installed games.

.DESCRIPTION
  This script uses PowerShell to force Steam to verify all files for the base installation and all installed games. It does this by locating the Steam executable and running it with the -verify_all flag. The script checks that it is running with administrator privileges, as it is necessary to have admin rights to access the Steam registry key. The script also checks if Steam is currently running, as it is not possible to verify files while the program is running.

.PARAMETER None
  This script does not take any parameters.

.EXAMPLE
  PS> .\verify_steam.ps1
  Forces Steam to verify all files for the base installation and all installed games.

.NOTES
  This script uses PowerShell to force Steam to verify all files for the base installation and all installed games. It does this by locating the Steam executable and running it with the -verify_all flag. The script checks that it is running with administrator privileges, as it is necessary to have admin rights to access the Steam registry key. The script also checks if Steam is currently running, as it is not possible to verify files while the program is running. This script should be used with caution, as it modifies system configurations and can potentially cause issues if used improperly.
#>

# Ensure that the script is running with administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning 'Please run this script as an administrator.'
    exit
}

# Find the location of the Steam executable
$steam = (Get-ItemProperty 'HKCU:\Software\Valve\Steam').SteamExe

# Check if Steam is running
if (Get-Process -Name 'Steam' -ErrorAction SilentlyContinue) {
    Write-Warning 'Steam is running. Please exit Steam and try again.'
    exit
}

# Verify the base installation
Start-Process -FilePath $steam -ArgumentList '-verify_all' -Wait

# Find the location of the steamapps folder
$steamapps = Join-Path (Split-Path $steam -Parent) 'steamapps'

# Verify the files for all installed games
if (Test-Path $steamapps) {
    Get-ChildItem $steamapps -Directory | ForEach-Object {
        $game = $_.Name
        $appmanifest = Join-Path $_.FullName "$game.appmanifest"
        if (Test-Path $appmanifest) {
            $appid = Get-Content $appmanifest | Select-String -Pattern '"appid"\s*"\d+"' | ForEach-Object {
                $_ -replace '.*"appid"\s*"?(\d+)".*', '$1'
            }
            if ($appid) {
                Write-Host "Verifying files for $game (AppID: $appid)..."
                Start-Process -FilePath $steam -ArgumentList "-applaunch $appid -verify_all" -Wait
            }
        }
    }
}

# Output a message to indicate that the verification is complete
Write-Host 'Verification of all installed files is complete.'