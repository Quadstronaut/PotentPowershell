<#
.SYNOPSIS
  Configures the AWS CLI with a new profile.

.DESCRIPTION
  This script configures the AWS CLI with a new profile by prompting the user for the profile name, access key, and secret key.
  The profile will be stored in the credentials file located in the user's home directory.

.PARAMETER None
  This script does not take any parameters.

.EXAMPLE
  PS> .\cli_configure.ps1
  Configures the AWS CLI with a new profile.

.NOTES
  This script requires the AWS CLI to be installed on the system. The script prompts the user to enter the following information for the new profile:
  * Profile name
  * Access key
  * Secret key
  The profile is then added to the credentials file located in the user's home directory. If the credentials file does not exist, it will be created.
#>

# Check for saved access and secret keys
if ((Test-Path $env:USERPROFILE\.aws\credentials) -and (Select-String -Path $env:USERPROFILE\.aws\credentials -Pattern 'aws_access_key_id')) {
    Write-Host 'Saved AWS credentials found.'
    $useSaved = Read-Host 'Would you like to use the saved credentials? (Y/N)'
    if ($useSaved -eq 'Y') {
        Write-Host 'Using saved credentials.'
        $accessKey = Select-String -Path $env:USERPROFILE\.aws\credentials -Pattern 'aws_access_key_id\s*=\s*(\S+)' | ForEach-Object { $_.Matches[0].Groups[1].Value }
        $secretKey = Select-String -Path $env:USERPROFILE\.aws\credentials -Pattern 'aws_secret_access_key\s*=\s*(\S+)' | ForEach-Object { $_.Matches[0].Groups[1].Value }
    }
    else {
        $accessKey = Read-Host 'Enter your AWS access key:'
        $secretKey = Read-Host 'Enter your AWS secret key:'
    }
}
else {
    $accessKey = Read-Host 'Enter your AWS access key:'
    $secretKey = Read-Host 'Enter your AWS secret key:'
}

# Install Chocolatey if not already installed
if (!(Test-Path 'C:\ProgramData\chocolatey\choco.exe')) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Update AWS CLI and AWS Tools for PowerShell
choco upgrade awscli awstools.powershell -y

# Configure AWS CLI
aws configure set aws_access_key_id $accessKey
aws configure set aws_secret_access_key $secretKey

# Determine closest AWS region
$regions = (aws ec2 describe-regions --query Regions[*].RegionName --output text).Split()
$regionList = ''
for ($i = 0; $i -lt $regions.Length; $i++) {
    $regionList += "`n$($i+1): $($regions[$i])"
}
$regionChoice = Read-Host "Select the closest AWS region:`n$regionList"
$region = $regions[$regionChoice - 1]

# Configure default region for AWS CLI
aws configure set default.region $region

# Test AWS configuration
Write-Host 'Testing AWS configuration...'
aws s3 ls > $null
if ($LastExitCode -eq 0) {
    Write-Host 'AWS CLI and AWS Tools for PowerShell have been successfully configured.'
}
else {
    Write-Host 'There was an error configuring AWS. Please check your access key, secret key, and region settings and try again.'
}