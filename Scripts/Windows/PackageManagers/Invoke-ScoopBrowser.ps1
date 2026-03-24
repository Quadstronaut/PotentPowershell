<#
.SYNOPSIS
    Interactive browser for Scoop packages — shows info and installs in background.

.DESCRIPTION
    Iterates all available Scoop packages. For each one, displays package info
    and prompts the user with a Y/N keypress. If Y, installs the package as a
    background job so browsing continues uninterrupted.

    At the end, lists all running installation jobs and how to retrieve their output.

.PARAMETER None
    No parameters. Requires Scoop to be installed.

.EXAMPLE
    PS> .\Invoke-ScoopBrowser.ps1

.NOTES
    Author   : Quadstronaut
    Requires : Scoop (https://scoop.sh)
#>

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop is not installed. Visit https://scoop.sh to install it." -ForegroundColor Red
    exit 1
}

$scoopOutput = (scoop search | Out-String).Split("`n")

foreach ($line in $scoopOutput) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }

    $packageName = ($line.Trim() -split '\s+')[0]

    Clear-Host
    Write-Host "--- Package Info: '$packageName' ---" -ForegroundColor Cyan
    scoop info $packageName
    Write-Host "--------------------------------------" -ForegroundColor Cyan
    Write-Host "Install '$packageName'? (Y/N)" -NoNewline

    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp").Character
    Write-Host ""

    while ($key -ne 'y' -and $key -ne 'Y' -and $key -ne 'n' -and $key -ne 'N') {
        Write-Host "Press Y or N." -ForegroundColor Red -NoNewline
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp").Character
        Write-Host ""
    }

    if ($key -eq 'y' -or $key -eq 'Y') {
        Write-Host "Installing '$packageName' in the background..." -ForegroundColor Green
        Start-Job -Name "ScoopInstall-$packageName" -ScriptBlock {
            param($name)
            scoop install $name
        } -ArgumentList $packageName
    }
    else {
        Write-Host "Skipping '$packageName'." -ForegroundColor Yellow
    }
    Write-Host ""
}

# Show all queued installation jobs
$jobs = Get-Job -State Running
if ($jobs) {
    Write-Host "`nActive installation jobs:" -ForegroundColor Cyan
    $jobs | Format-Table Id, Name, State
    Write-Host "To see output: Receive-Job -Id <JobId>"
}
else {
    Write-Host "No installations running."
}
