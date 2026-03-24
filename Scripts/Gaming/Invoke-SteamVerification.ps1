<#
.SYNOPSIS
    Forces Steam to verify all installed game files.

.DESCRIPTION
    Locates the Steam executable via the registry, then runs Steam with -verify_all
    to validate the base installation. Iterates all steamapps subdirectories and
    triggers per-game verification via -applaunch <appid> -verify_all.

.PARAMETER None
    No parameters — requires administrator privileges (registry access).

.EXAMPLE
    PS> .\Invoke-SteamVerification.ps1

.NOTES
    Author   : Quadstronaut
    Requires : Steam, administrator privileges
#>

# Ensure script is running as administrator (needed for registry access)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning 'Please run this script as an administrator.'
    exit
}

# Find the Steam executable from registry
$steam = (Get-ItemProperty 'HKCU:\Software\Valve\Steam').SteamExe

# Abort if Steam is currently running
if (Get-Process -Name 'Steam' -ErrorAction SilentlyContinue) {
    Write-Warning 'Steam is running. Please exit Steam and try again.'
    exit
}

# Verify the base Steam installation
Write-Host "Verifying Steam base installation..."
Start-Process -FilePath $steam -ArgumentList '-verify_all' -Wait

# Verify each installed game
$steamapps = Join-Path (Split-Path $steam -Parent) 'steamapps'

if (Test-Path $steamapps) {
    Get-ChildItem $steamapps -Directory | ForEach-Object {
        $game        = $_.Name
        $appmanifest = Join-Path $_.FullName "$game.appmanifest"

        if (Test-Path $appmanifest) {
            $appid = Get-Content $appmanifest |
                Select-String -Pattern '"appid"\s*"\d+"' |
                ForEach-Object { $_ -replace '.*"appid"\s*"?(\d+)".*', '$1' }

            if ($appid) {
                Write-Host "Verifying $game (AppID: $appid)..."
                Start-Process -FilePath $steam -ArgumentList "-applaunch $appid -verify_all" -Wait
            }
        }
    }
}

Write-Host 'Verification of all installed files is complete.'
