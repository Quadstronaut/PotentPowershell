<#
.SYNOPSIS
    Posts a rich embed message to a Discord channel via webhook.

.DESCRIPTION
    Constructs a Discord embed payload and sends it to a webhook URL via REST.
    Supports title, description, color, thumbnail image, and author metadata.

.PARAMETER WebhookUrl
    The webhook URL for the target Discord channel.

.PARAMETER Title
    The title for the rich embed message.

.PARAMETER Description
    The description (body text) for the rich embed message.

.PARAMETER Color
    The left-border color in decimal integer format (Discord API uses decimal, not hex).
    Default: 65280 (0x00FF00, green). Use a hex-to-decimal converter if needed.

.PARAMETER Thumbnail
    Optional URL for a thumbnail image displayed in the embed.

.PARAMETER Author
    Optional hashtable with 'name' and 'icon_url' keys for the embed author field.

.EXAMPLE
    PS> .\Send-RichEmbed.ps1 `
            -WebhookUrl "https://discord.com/api/webhooks/..." `
            -Title "Deployment Complete" `
            -Description "Build 1.2.3 deployed successfully." `
            -Color 65280

.EXAMPLE
    PS> $author = @{ name = "CI Bot"; icon_url = "https://example.com/bot.png" }
    PS> .\Send-RichEmbed.ps1 -WebhookUrl $url -Title "Alert" -Description "Disk full" -Author $author

.NOTES
    Author  : Quadstronaut
    Requires: PowerShell 3.0+, a valid Discord webhook URL
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$WebhookUrl,

    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [string]$Description,

    [Parameter(Mandatory = $false)]
    [int]$Color = 65280,   # decimal — Discord API requires decimal, not hex strings

    [Parameter(Mandatory = $false)]
    [string]$Thumbnail,

    [Parameter(Mandatory = $false)]
    [hashtable]$Author
)

# Build the embed object
$embedObject = @{
    title       = $Title
    description = $Description
    color       = $Color
}

if ($Thumbnail) {
    $embedObject['thumbnail'] = @{ url = $Thumbnail }
}

if ($Author) {
    $embedObject['author'] = $Author
}

# Build the full webhook payload
$payload = @{
    username   = 'PowerShell Bot'
    avatar_url = 'https://raw.githubusercontent.com/PowerShell/PowerShell/master/assets/ps_black_64.svg'
    embeds     = @($embedObject)
} | ConvertTo-Json -Depth 10

# Send the POST request
Invoke-RestMethod -Uri $WebhookUrl -Method POST -Body $payload -ContentType 'application/json'
