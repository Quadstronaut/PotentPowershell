$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$url = 'https://alfilatov.com/MSEdgeSearchClicker/'

# Check if Edge exists at the specified path
if (-not (Test-Path $edgePath)) {
    Write-Error "Microsoft Edge not found at '$edgePath'"
    Exit 1
}

# Launch Edge with the specified URL
try {
    $edgeProcess = Start-Process -FilePath $edgePath -ArgumentList $url -PassThru -ErrorAction Stop
    # Wait for 60 seconds and terminate Edge
    Start-Sleep -Seconds 60
    if (-not $edgeProcess.HasExited) {
        $edgeProcess.Kill()
    }
} catch {
    Write-Error "Failed to launch Microsoft Edge: $_"
    Exit 1
}