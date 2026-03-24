<#
.SYNOPSIS
    Synchronizes two directories using Robocopy.

.DESCRIPTION
    Copies all files from source to destination, skipping files that already exist
    with the same timestamp (/XC), showing no per-file progress (/NP) but an ETA,
    using 64 parallel threads (/MT:64) for maximum throughput.

    Suitable for backup, staging, or mirroring scenarios.

.PARAMETER Source
    The source directory to copy from.

.PARAMETER Destination
    The destination directory to copy to.

.EXAMPLE
    PS> .\Sync-Directories.ps1 -Source "D:\Data" -Destination "E:\Backup\Data"

.EXAMPLE
    PS> .\Sync-Directories.ps1 -Source "\\server\share" -Destination "C:\LocalCopy"

.NOTES
    Author   : Quadstronaut
    Requires : Robocopy (included with Windows Vista+)
    Note     : /MT:64 uses 64 threads. Reduce if it causes issues on slow storage.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Source,

    [Parameter(Mandatory = $true)]
    [string]$Destination
)

Write-Verbose "Syncing '$Source' → '$Destination'..."
Robocopy $Source $Destination /E /XC /NP /ETA /MT:64

# Robocopy exit codes:
# 0 = No files copied (destination already in sync)
# 1 = Files copied successfully
# 2 = Extra files/directories detected in destination
# 4 = Mismatched files detected
# 8 = Some files/directories could not be copied (check log)
# 16 = Fatal error
if ($LASTEXITCODE -le 3) {
    Write-Host "Sync complete (exit code $LASTEXITCODE — success)."
}
else {
    Write-Warning "Robocopy exited with code $LASTEXITCODE — some files may not have copied."
}
