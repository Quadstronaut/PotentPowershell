<#
.SYNOPSIS
    Bootstraps a new AWS account with IAM users, MFA guidance, billing alarms, and SSO.

.DESCRIPTION
    Walks through the AWS account hardening checklist:
      1. Configure credentials (reuse existing or enter new)
      2. Create an IAM user and group with a policy
      3. Set up billing budgets and alerts
      4. Create a VPC, security group, EC2 instance (via Terraform guidance)
      5. Configure CloudTrail
      6. Create an admin IAM account and disable root SSH
      7. Configure AWS SSO
      8. Enable MFA on the admin account

    Several steps require manual action or Terraform — the script notes these clearly.

.EXAMPLE
    PS> .\New-AwsAccount.ps1

.NOTES
    Author  : Quadstronaut
    Requires: AWSPowerShell or AWS.Tools modules, admin rights
#>

# STEP 1: Configure AWS CLI with your access keys
$existingCredentials = Get-AWSCredential -ListProfileDetail

if ($existingCredentials -ne $null) {
    Write-Host "Existing AWS credentials found:`n"
    Write-Host "Access key ID: $($existingCredentials[0].AccessKey)"
    Write-Host "Secret access key: $($existingCredentials[0].SecretKey)`n"
    $useExistingCredentials = Read-Host 'Do you want to use the existing AWS credentials? (y/n)'

    if ($useExistingCredentials -eq 'y') {
        $existingProfile = Read-Host 'Enter the name of the AWS profile to use (e.g. default)'
        Set-AWSCredential -ProfileName $existingProfile
    }
}

if ($existingCredentials -eq $null -or $useExistingCredentials -eq 'n') {
    $accessKey   = Read-Host 'Enter your AWS access key ID'
    $secretKey   = Read-Host 'Enter your AWS secret access key'
    $profileName = Read-Host 'Enter the name of the AWS profile to use (e.g. default)'
    Set-AWSCredential -AccessKey $accessKey -SecretKey $secretKey -ProfileName $profileName
}

# STEP 2: Enable MFA on your root account
# This step cannot be automated since it requires a physical MFA device.
Write-Host "STEP 2: Enable MFA on the root account manually in the AWS Console."

# STEP 3: Create an IAM user with limited permissions
$iamUserName  = Read-Host 'Enter the IAM user name to create'
$iamGroupName = Read-Host 'Enter the IAM group name to create'

New-IAMUser  -UserName $iamUserName  | Out-Null
New-IAMGroup -GroupName $iamGroupName | Out-Null
Add-IAMUserToGroup -UserName $iamUserName -GroupName $iamGroupName | Out-Null

$policyName     = Read-Host 'Enter the IAM policy name'
$policyDocument = Get-Content (Read-Host 'Enter path to JSON policy document')

New-IAMPolicy -PolicyName $policyName -PolicyDocument $policyDocument | Out-Null

$accountId = (Get-STSCallerIdentity).Account
Attach-IAMPolicyToGroup -PolicyArn "arn:aws:iam::${accountId}:policy/$policyName" -GroupName $iamGroupName | Out-Null
New-IAMAccessKey -UserName $iamUserName | Out-Null

# STEP 4: Set up a billing alarm
$budgetName        = 'Monthly-Budget'
$budgetDescription = 'Monthly budget for AWS spending'
$budgetAmount      = 50
$budgetTimeUnit    = 'MONTHLY'

$filters = @(
    @{ Name = 'SERVICE'; Values = '*' },
    @{ Name = 'REGION';  Values = '*' }
)

New-Budget -BudgetName $budgetName -BudgetType COST -BudgetLimit $budgetAmount `
    -TimeUnit $budgetTimeUnit -BudgetFilter $filters -BudgetDescription $budgetDescription

$snsArn = Read-Host 'Enter your SNS topic ARN for billing alerts'
New-BudgetAction -ActionName 'Monthly-Spending-80%-Alert'  -NotificationType ACTUAL -Threshold 80  -ThresholdType PERCENTAGE -ActionType FORECASTED -Notification $snsArn
New-BudgetAction -ActionName 'Monthly-Spending-100%-Alert' -NotificationType ACTUAL -Threshold 100 -ThresholdType PERCENTAGE -ActionType ACTUAL     -Notification $snsArn

# STEPS 5-7: VPC, security group, EC2 — use Terraform
Write-Host "STEPS 5-7: Configure VPC, security group, and EC2 via Terraform."

# STEP 8: Create an Elastic IP
New-EC2Address | Out-Null

# STEP 9: S3 bucket — use Terraform or Console

# STEP 10: Set up CloudTrail
$cloudTrailName = Read-Host 'Enter CloudTrail name'
$s3BucketName   = Read-Host 'Enter S3 bucket name for CloudTrail logs'
New-CloudTrail -Name $cloudTrailName -S3BucketName $s3BucketName | Out-Null

# STEP 11: Create admin account and disable root SSH
$adminUsername = Read-Host 'Enter admin username'
$user = Get-IAMUser -UserName $adminUsername -ErrorAction SilentlyContinue
if (-not $user) { New-IAMUser -UserName $adminUsername }
Add-IAMUserToGroup -UserName $adminUsername -GroupName 'Administrators'

# STEP 12: Configure AWS SSO
Install-Module -Name AWSPowerShellSSO -Force
Import-Module  -Name AWSPowerShellSSO
Initialize-AWSSSO

$awsSsoAccountId  = Read-Host 'Enter your AWS account ID'
$awsSsoRole       = Read-Host 'Enter SSO role name (e.g. AWSReservedSSO_AdministratorAccess_...)'
$awsSsoStartUrl   = Read-Host 'Enter SSO start URL (e.g. https://<instance>.awsapps.com/start)'
Add-AWSSSORoleToProfile -ProfileName 'default' -RoleName $awsSsoRole -AccountId $awsSsoAccountId -StartUrl $awsSsoStartUrl

# STEP 13: Enable MFA on the admin account
$serialNumber = Read-Host 'Enter MFA device serial number'
Enable-IAMMFA -UserName $adminUsername -SerialNumber $serialNumber
$otp = Read-Host 'Enter current MFA token'
Test-IAMMFA -ProfileName 'default' -OTPCode $otp
