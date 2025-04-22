### USER CONFIG ###

$Accounts = @("Unistronaut", "Bistronaut", "Tristronaut", "Quadstronaut") # These are your in-game CMDR names
$Sandboxes = @("CMDR_Unistronaut", "CMDR_Bistronaut", "CMDR_Tristronaut", "CMDR_Quadstronaut") # Sandboxie treats spaces as underscores in sandbox names

### END CONFIG ###

Get-Process *steam* | Stop-Process -Force
$DefaultGamePath = "C:\Program Files (x86)\Steam\steamapps\common\Elite Dangerous\MinEdLauncher.exe"
if (Test-Path -Path $DefaultGamePath -PathType Leaf) {
    $GamePath = $DefaultGamePath
}
else {
    # Get all drives
    $Drives = Get-PSDrive -PSProvider FileSystem

    # Iterate through each drive
    foreach ($Drive in $Drives) {
        $DriveLetter = $Drive.Root

        # Check for "Program Files" and "Steam" in the root of the drive
        $ProgramFilesPath = Join-Path $DriveLetter "Program Files (x86)\Steam\steamapps\common\Elite Dangerous\MinEdLauncher.exe"
        $ProgramFiles64Path = Join-Path $DriveLetter "Program Files\Steam\steamapps\common\Elite Dangerous\MinEdLauncher.exe"
        $SteamPath = Join-Path $DriveLetter "Steam\steamapps\common\Elite Dangerous\MinEdLauncher.exe"

        # Check if the file exists in any predefined path
        if (Test-Path -Path $ProgramFilesPath -PathType Leaf) { $GamePath = $ProgramFilesPath }
        elseif (Test-Path -Path $ProgramFiles64Path -PathType Leaf) { $GamePath = $ProgramFiles64Path }
        elseif (Test-Path -Path $SteamPath -PathType Leaf) { $GamePath = $SteamPath }
        else { Continue }
    }
}

# Define potential Sandboxie Start.exe paths in order of preference
$PossibleSandboxiePaths = @(
    "$($env:USERPROFILE)\scoop\apps\sandboxie-plus-np\current\Start.exe",
    "$(Join-Path $env:ProgramData 'chocolatey\bin\Start.exe')",
    "$($env:LOCALAPPDATA)\Programs\Sandboxie\Start.exe",
    "$(Join-Path $env:ProgramFiles 'Sandboxie-Plus')\Start.exe",
    "$(Join-Path $env:ProgramFiles`(x86`) 'Sandboxie-Plus\Start.exe')"
)

# Test for Sandboxie
$SandboxiePath = $null
foreach ($Path in $PossibleSandboxiePaths) {
    if (Test-Path -Path $Path -PathType Leaf) { $SandboxiePath = $Path; break }
}
try {
    if (-not $SandboxiePath) {
        Write-Host "Start.exe not found in any of the following locations:" -ForegroundColor Red
        foreach ($Path in $PossibleSandboxiePaths) {
            Write-Host "$Path" -ForegroundColor Red
        }
        Write-Host "Please ensure Sandboxie Plus is installed." -ForegroundColor Red
    }
    else {
        # Iterate the sandboxes
        for ($i = 0; $i -lt $Sandboxes.Count; $i++) {
            $SandboxName = $Sandboxes[$i]
            $AccountName = $Accounts[$i]

            # Prefer Odyssey over Horizons
            $OdysseyCheckPath = Split-Path $GamePath -Parent
            $OdysseyCheckPath = Join-Path $OdysseyCheckPath "Products\elite-dangerous-odyssey-64"
            $SteamArguments = "/frontier $($AccountName) /autorun /autoquit /ed$(if (Test-Path -Path $OdysseyCheckPath -PathType Container) {'o'} else {'h'})"
            $CommandLine = "$SandboxiePath /box:`"$SandboxName`" `"$GamePath`" $($SteamArguments)"
            Write-Host "Executing: $CommandLine" -ForegroundColor Yellow
            try {
                Invoke-Expression $CommandLine
            }
            catch { Write-Host "Error executing command: $($_.Exception.Message) - $($_.Exception.InnerException.Message)" -ForegroundColor Red }
        }
    }
}
finally { exit }
