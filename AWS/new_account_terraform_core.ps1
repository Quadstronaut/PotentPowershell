# Check if Chocolatey is installed, if not install it
if (!(Test-Path 'C:\ProgramData\chocolatey\bin\choco.exe')) {
    Write-Host 'Chocolatey is not installed. Installing...'
    Set-ExecutionPolicy Bypass -Scope Process -Force
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Check if AWS CLI is installed, if not install it
if (!(Test-Path 'C:\Program Files\Amazon\AWSCLI\aws.exe')) {
    Write-Host 'AWS CLI is not installed. Installing...'
    choco install awscli -y
}

# Check if AWS Tools for PowerShell is installed, if not install it
if (!(Get-Module -ListAvailable AWSPowerShell)) {
    Write-Host 'AWS Tools for PowerShell is not installed. Installing...'
    choco install awstools -y
}

# Get AWS access keys and default region from user or environment variables
$accessKey = Read-Host 'Enter your AWS access key ID'
$secretKey = Read-Host 'Enter your AWS secret access key' -AsSecureString
$defaultRegion = Read-Host 'Enter your default AWS region'

if (-not $accessKey -or -not $secretKey -or -not $defaultRegion) {
    $accessKey = $env:AWS_ACCESS_KEY_ID
    $secretKey = $env:AWS_SECRET_ACCESS_KEY | ConvertTo-SecureString
    $defaultRegion = $env:AWS_DEFAULT_REGION

    if (-not $accessKey -or -not $secretKey -or -not $defaultRegion) {
        Write-Error 'AWS access keys or default region are not set. Aborting.'
        Exit
    }
}

# Set AWS access keys and default region
Set-AWSCredential -AccessKey $accessKey -SecretKey $secretKey
Set-DefaultAWSRegion -Region $defaultRegion

# Create a new VPC
$vpcCidrBlock = '10.0.0.0/16'
$vpcName = 'MyVPC'
$vpc = New-EC2Vpc -CidrBlock $vpcCidrBlock -InstanceTenancy 'default' -Tag @{Name=$vpcName}

# Create subnets
$subnetCidrBlocks = '10.0.1.0/24', '10.0.2.0/24', '10.0.3.0/24'
$subnetNames = 'Public', 'Private1', 'Private2'
$subnets = New-EC2Subnet -VpcId $vpc.VpcId -CidrBlock $subnetCidrBlocks -AvailabilityZone $defaultRegion + 'a' -Tag @{Name=$subnetNames}

# Create an internet gateway
$igwName = 'MyIGW'
$igw = New-EC2InternetGateway -Tag @{Name=$igwName}

# Attach the internet gateway to the VPC
Add-EC2InternetGateway -InternetGatewayId $igw.InternetGatewayId -VpcId $vpc.VpcId

# Create a route table for public subnets
$publicRouteTableName = 'PublicRouteTable'
$publicRouteTable = New-EC2RouteTable -VpcId $vpc.VpcId -Tag @{Name=$publicRouteTableName}

# Associate the public subnets with the public route table
$publicSubnets = $subnets | Where-Object { $_.Tags.Name -eq 'Public' }
$publicSubnets
