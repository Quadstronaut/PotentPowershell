# Get a list of all available packages using 'scoop search'.
# The output is captured as a string and then split into individual lines.
$scoopOutput = (scoop search | Out-String).Split("`n")

# Loop through each line of the Scoop output
foreach ($line in $scoopOutput) {
    # Skip any empty lines
    if ([string]::IsNullOrWhiteSpace($line)) {
        continue
    }

    # Extract the package name, which is the first word of the line
    $packageName = ($line.Trim() -split '\s+')[0]

    # Display the package info using 'scoop info' before prompting
    Clear-Host
    Write-Host "--- Package Info for '$packageName' ---" -ForegroundColor Cyan
    scoop info $packageName
    Write-Host "-------------------------------------" -ForegroundColor Cyan

    Write-Host "Do you want to install '$packageName'? (Y/N)" -NoNewline

    # Get user input and validate it
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp").Character
    Write-Host ""
    while ($key -ne 'y' -and $key -ne 'Y' -and $key -ne 'n' -and $key -ne 'N') {
        Write-Host "Invalid input. Please press 'Y' or 'N'." -ForegroundColor Red -NoNewline
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp").Character
        Write-Host ""
    }

    # Start a background job if the user chose to install
    if ($key -eq 'y' -or $key -eq 'Y') {
        Write-Host "Starting installation for '$packageName' in the background..." -ForegroundColor Green
        # Use Start-Job to run the install command as a non-blocking process.
        # It's important to pass the variable into the script block using $using:
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

Get-Job -
Write-Host "To see the output of a job, run 'Receive-Job -Id <JobId>'."