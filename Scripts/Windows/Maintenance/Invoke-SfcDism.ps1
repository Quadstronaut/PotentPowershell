<#
.SYNOPSIS
    Reference script for SFC and DISM system repair commands.

.DESCRIPTION
    Documents the most useful sfc.exe and dism.exe commands for diagnosing and
    repairing Windows system files and the component store. Run commands
    individually as needed — they are not all meant to be run sequentially.

    All commands require administrator privileges.

.EXAMPLE
    PS> .\Invoke-SfcDism.ps1   # review the commands, then run desired ones manually

.NOTES
    Author   : Quadstronaut
    Requires : Administrator privileges, Windows (not PowerShell Core on Linux)
#>

# --- SYSTEM FILE CHECKER (SFC) ---

# Scan and repair all protected system files:
sfc /scannow

# Verify integrity without repairing:
sfc /verifyonly

# Scan and repair a single file:
sfc /scanfile=C:\Windows\System32\calc.exe

# Scan an offline Windows installation:
sfc /offwindir=C:\Win /offbootdir=C:\Win /scanfile=C:\Win\System32\calc.exe

# --- DEPLOYMENT IMAGE SERVICING AND MANAGEMENT (DISM) ---

# Scan and repair the Windows image (downloads from Windows Update if needed):
dism /online /cleanup-image /restorehealth

# Clean up the WinSxS folder (removes superseded components):
dism /online /cleanup-image /startcomponentcleanup

# Deep cleanup — resets base and cannot be undone (saves the most space):
dism /online /cleanup-image /startcomponentcleanup /resetbase

# Analyze the component store and report potential savings:
dism /online /cleanup-image /analyzecomponentstore

# List all installed packages and their states:
dism /online /get-packages

# --- RECOMMENDED REPAIR SEQUENCE ---
# 1. Run DISM first to ensure the Windows image is healthy.
# 2. Then run SFC to repair individual system files using the healthy image.
#
# dism /online /cleanup-image /restorehealth
# sfc /scannow
