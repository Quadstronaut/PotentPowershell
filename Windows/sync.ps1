$source = "<#CHANGEME#>"
$destination = "<#CHANGEME#>"

# Use Robocopy to synchronize the directories
Robocopy $source $destination /E /XC /NP /ETA /MT:64
