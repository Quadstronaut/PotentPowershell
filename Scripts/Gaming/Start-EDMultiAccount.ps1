<#
.SYNOPSIS
    Launches multiple Elite Dangerous accounts simultaneously via Sandboxie.

.DESCRIPTION
    Finds the Elite Dangerous MinEdLauncher executable across common install paths,
    detects the installed Sandboxie Plus binary, then launches each configured
    account in its own sandbox with the appropriate Odyssey or Horizons flag.

    Stops Steam before launching to prevent single-account enforcement.

.PARAMETER None
    Configure accounts and sandboxes in the USER CONFIG section at the top of the script.

.EXAMPLE
    PS> .\Start-EDMultiAccount.ps1

.NOTES
    Author   : Quadstronaut
    Requires : Sandboxie Plus, Elite Dangerous via Steam, MinEdLauncher
    License  : MIT
#>

### USER CONFIG ###

$Accounts  = @("Unistronaut", "Bistronaut", "Tristronaut", "Quadstronaut") # In-game CMDR names
$Sandboxes = @("CMDR_Unistronaut", "CMDR_Bistronaut", "CMDR_Tristronaut", "CMDR_Quadstronaut") # Sandboxie sandbox names (spaces become underscores)

### END CONFIG ###

Get-Process *steam* | Stop-Process -Force

$DefaultGamePath = "C:\Program Files (x86)\Steam\steamapps\common\Elite Dangerous\MinEdLauncher.exe"
if (Test-Path -Path $DefaultGamePath -PathType Leaf) {
    $GamePath = $DefaultGamePath
}
else {
    # Search all drives for the MinEdLauncher executable
    $Drives = Get-PSDrive -PSProvider FileSystem
    foreach ($Drive in $Drives) {
        $DriveLetter          = $Drive.Root
        $ProgramFilesPath     = Join-Path $DriveLetter "Program Files (x86)\Steam\steamapps\common\Elite Dangerous\MinEdLauncher.exe"
        $ProgramFiles64Path   = Join-Path $DriveLetter "Program Files\Steam\steamapps\common\Elite Dangerous\MinEdLauncher.exe"
        $SteamPath            = Join-Path $DriveLetter "Steam\steamapps\common\Elite Dangerous\MinEdLauncher.exe"

        if      (Test-Path -Path $ProgramFilesPath   -PathType Leaf) { $GamePath = $ProgramFilesPath;   break }
        elseif  (Test-Path -Path $ProgramFiles64Path -PathType Leaf) { $GamePath = $ProgramFiles64Path; break }
        elseif  (Test-Path -Path $SteamPath          -PathType Leaf) { $GamePath = $SteamPath;          break }
    }
}

# Locate Sandboxie Start.exe in common install locations
$PossibleSandboxiePaths = @(
    "$($env:USERPROFILE)\scoop\apps\sandboxie-plus-np\current\Start.exe",
    "$(Join-Path $env:ProgramData 'chocolatey\bin\Start.exe')",
    "$($env:LOCALAPPDATA)\Programs\Sandboxie\Start.exe",
    "$(Join-Path $env:ProgramFiles 'Sandboxie-Plus')\Start.exe",
    "$(Join-Path $env:ProgramFiles`(x86`) 'Sandboxie-Plus\Start.exe')"
)

$SandboxiePath = $null
foreach ($Path in $PossibleSandboxiePaths) {
    if (Test-Path -Path $Path -PathType Leaf) { $SandboxiePath = $Path; break }
}

try {
    if (-not $SandboxiePath) {
        Write-Host "Start.exe not found in any of the following locations:" -ForegroundColor Red
        $PossibleSandboxiePaths | ForEach-Object { Write-Host $_ -ForegroundColor Red }
        Write-Host "Please ensure Sandboxie Plus is installed." -ForegroundColor Red
    }
    else {
        for ($i = 0; $i -lt $Sandboxes.Count; $i++) {
            $SandboxName  = $Sandboxes[$i]
            $AccountName  = $Accounts[$i]

            # Prefer Odyssey if installed, fall back to Horizons
            $OdysseyCheckPath = Join-Path (Split-Path $GamePath -Parent) "Products\elite-dangerous-odyssey-64"
            $Edition          = if (Test-Path -Path $OdysseyCheckPath -PathType Container) { 'o' } else { 'h' }
            $SteamArguments   = "/frontier $AccountName /autorun /autoquit /ed$Edition"
            $CommandLine      = "$SandboxiePath /box:`"$SandboxName`" `"$GamePath`" $SteamArguments"

            Write-Host "Executing: $CommandLine" -ForegroundColor Yellow
            try {
                Invoke-Expression $CommandLine
            }
            catch {
                Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}
finally {
    exit
}
