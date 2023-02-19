<#
.SYNOPSIS
Posts a rich embed message to a Discord channel using a webhook URL.

.DESCRIPTION
This script utilizes the Discord webhook API to post a rich embed message to a Discord channel. The message can include a title, description, color, thumbnail, and author.

.PARAMETER WebhookUrl
The webhook URL for the target Discord channel.

.PARAMETER Title
The title for the rich embed message.

.PARAMETER Description
The description for the rich embed message.

.PARAMETER Color
The color of the left border of the rich embed message, specified in hex format (e.g. 0x00ff00 for green).

.PARAMETER Thumbnail
The URL for the thumbnail image to be included in the rich embed message.

.PARAMETER Author
The name and icon URL for the author of the rich embed message.

.EXAMPLE
.\Post-DiscordRichEmbed.ps1 -WebhookUrl "https://discord.com/api/webhooks/123456789012345678/abcdefghijklmno..." -Title "Example Embed Message" -Description "This is an example of a rich embed message posted via PowerShell." -Color "0x00ff00" -Thumbnail "https://www.example.com/image.png" -Author @{ "name" = "ChatGPT"; "icon_url" = "https://www.example.com/avatar.png" }

.NOTES
This script requires PowerShell version 3.0 or later.
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$WebhookUrl,

    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [string]$Description,

    [Parameter(Mandatory = $false)]
    [string]$Color = '0x00ff00',

    [Parameter(Mandatory = $false)]
    [string]$Thumbnail,

    [Parameter(Mandatory = $false)]
    [hashtable]$Author
)

# Construct the rich embed message object
$embedObject = @{
    'title'       = $Title
    'description' = $Description
    'color'       = $Color
}

if ($Thumbnail) {
    $embedObject['thumbnail'] = @{
        'url' = $Thumbnail
    }
}

if ($Author) {
    $embedObject['author'] = $Author
}

# Construct the JSON payload to be sent to the webhook URL
$payload = @{
    'username'   = 'PowerShell Bot'
    'avatar_url' = 'https://www.example.com/bot_avatar.png'
    'embeds'     = @($embedObject)
} | ConvertTo-Json

# Send the POST request to the webhook URL
Invoke-RestMethod -Uri $WebhookUrl -Method POST -Body $payload