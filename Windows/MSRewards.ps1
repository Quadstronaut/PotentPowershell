$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$url = 'https://greybax.github.io/MSEdgeSearchClicker'

# Check if Edge exists at the specified path
if (Test-Path $edgePath) {
    # Launch Edge with the specified URL
    try {
        Start-Process -FilePath $edgePath -ArgumentList $url -ErrorAction Stop
        # Wait for 60 seconds and terminate Edge
        Start-Sleep -Seconds 30
        Stop-Process -Name 'msedge' -ErrorAction Stop
    } catch {
        Exit 1
    }
}