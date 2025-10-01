Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$label = New-Object System.Windows.Forms.Label
$label.Text = "Move the mouse..."
$label.AutoSize = $true
$form.Controls.Add($label)

# Create a timer to update the label every 100 milliseconds
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 100 
$timer.Add_Tick({
    # Get the current mouse position relative to the screen
    $position = [System.Windows.Forms.Cursor]::Position
    
    # Update the label text
    $label.Text = "Mouse X: $($position.X), Y: $($position.Y)"
})

# Start the timer and show the form
$timer.Start()
[void]$form.ShowDialog() 

# Clean up (optional, but good practice)
$timer.Stop()
$timer.Dispose()
$form.Dispose()