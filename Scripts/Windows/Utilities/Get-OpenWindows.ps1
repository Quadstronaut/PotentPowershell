<#
.SYNOPSIS
    Lists all open application windows with their process name and window title.

.DESCRIPTION
    Iterates all running processes that have a main window handle and outputs their
    ProcessName and MainWindowTitle. Useful for identifying the correct window title
    string to use in automation scripts (e.g., for window positioning or focus control).

.PARAMETER None
    No parameters.

.EXAMPLE
    PS> .\Get-OpenWindows.ps1
    --- Active Window Titles ---
    ProcessName     MainWindowTitle
    ...

.NOTES
    Author : Quadstronaut
#>

Write-Host "--- Active Window Titles ---"
Write-Host "ProcessName`t`tMainWindowTitle"
Write-Host "--------------------------------------------------------"

Get-Process |
    Where-Object { -not [string]::IsNullOrEmpty($_.MainWindowTitle) } |
    ForEach-Object {
        Write-Host "$($_.ProcessName)`t`t$($_.MainWindowTitle)"
    }

Write-Host "--------------------------------------------------------"
Write-Host "Use 'MainWindowTitle' from this list for window targeting in scripts."
