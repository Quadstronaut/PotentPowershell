Param(
    [string]$source = "<#CHANGEME#>",
    [string]$destination = "<#CHANGEME#>"
)

# Use Robocopy to synchronize the directories
Robocopy $source $destination /E /XC /NP /ETA /MT:64

# Use Robocopy to synchronize the directories
Robocopy $source $destination /E /XC /NP /ETA /MT:64
