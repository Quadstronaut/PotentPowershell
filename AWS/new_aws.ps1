# STEP 1: Configure AWS CLI with your access keys
# Check if AWS credentials exist
$existingCredentials = Get-AWSCredential -ListProfileDetail

if ($existingCredentials -ne $null) {
    # Prompt the user to use existing credentials or enter new ones
    Write-Host "Existing AWS credentials found:`n"
    Write-Host "Access key ID: $($existingCredentials[0].AccessKey)"
    Write-Host "Secret access key: $($existingCredentials[0].SecretKey)`n"
    $useExistingCredentials = Read-Host "Do you want to use the existing AWS credentials? (y/n)"

    if ($useExistingCredentials -eq "y") {
        # Use existing credentials
        $existingProfile = Read-Host "Enter the name of the AWS profile to use (e.g. default)"
        Set-AWSCredential -ProfileName $existingProfile
    }
}

if ($existingCredentials -eq $null -or $useExistingCredentials -eq "n") {
    # Query the user for new AWS credentials
    $accessKey = Read-Host "Enter your AWS access key ID"
    $secretKey = Read-Host "Enter your AWS secret access key"
    $profileName = Read-Host "Enter the name of the AWS profile to use (e.g. default)"

    # Save the credentials as the default for future use
    Set-AWSCredential -AccessKey $accessKey -SecretKey $secretKey -ProfileName $profileName
}

# STEP 2: Enable MFA on your root account
# This step cannot be automated since it requires a physical MFA device

# STEP 3: Create an IAM user with limited permissions and grant it access keys
$iamUserName = "IAM_USER_NAME_HERE"
$iamGroupName = "IAM_GROUP_NAME_HERE"

# Create the IAM user
New-IAMUser -UserName $iamUserName | Out-Null

# Create the IAM group
New-IAMGroup -GroupName $iamGroupName | Out-Null

# Add the IAM user to the group
Add-IAMUserToGroup -UserName $iamUserName -GroupName $iamGroupName | Out-Null

# Create a policy that grants the IAM user the required permissions
# This step requires you to create a JSON policy document that specifies the permissions
# that you want to grant to the IAM user
$policyName = "IAM_POLICY_NAME_HERE"
$policyDocument = Get-Content "PATH_TO_JSON_POLICY_DOCUMENT" # or "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess" to use AWS-managed policies

New-IAMPolicy -PolicyName $policyName -PolicyDocument $policyDocument | Out-Null

# Attach the policy to the IAM group
Attach-IAMPolicyToGroup -PolicyArn "arn:aws:iam::ACCOUNT_ID_HERE:policy/$policyName" -GroupName $iamGroupName | Out-Null

# Generate access keys for the IAM user
New-IAMAccessKey -UserName $iamUserName | Out-Null

# STEP 4: Set up a billing alarm
# This step cannot be automated since it requires manual configuration in the AWS Management Console

# STEP 5: Create a Virtual Private Cloud (VPC)
# This step requires you to define the VPC configuration parameters and execute them with Terraform
# A sample Terraform configuration file for creating a VPC can be found at:
# https://github.com/hashicorp/terraform/blob/master/examples/aws-two-tier/main.tf

# STEP 6: Create a security group for the VPC
# This step requires you to define the security group configuration parameters and execute them with Terraform
# A sample Terraform configuration file for creating a security group can be found at:
# https://github.com/hashicorp/terraform/blob/master/examples/aws-two-tier/modules/security-group/main.tf

# STEP 7: Create an EC2 instance
# This step requires you to define the EC2 instance configuration parameters and execute them with Terraform
# A sample Terraform configuration file for creating an EC2 instance can be found at:
# https://github.com/hashicorp/terraform/blob/master/examples/aws-two-tier/modules/web-server-cluster/main.tf

# STEP 8: Create an Elastic IP address for the EC2 instance
New-EC2Address | Out-Null

# STEP 9: Create an S3 bucket
# This step requires you to define the S3 bucket configuration parameters and execute them with Terraform
# A sample Terraform configuration file for creating an S3 bucket can be found at:
# https://github.com/hashicorp/terraform/blob/master/examples/aws-s3-bucket/main.tf

# STEP 10: Set up CloudTrail
# This step requires you to create a CloudTrail trail and specify the S3 bucket where the trail logs will be stored
# This can be achieved with the following PowerShell command:
New-CloudTrail -Name "CLOUDTRAIL_NAME_HERE" -S3BucketName "S3_BUCKET_NAME_HERE" | Out-Null

# STEP 11: Set
# 11. Create a new user account with administrative permissions and disable root access
$adminUsername = "<your_admin_username>"
$user = Get-IAMUser -UserName $adminUsername
if (!$user) {
    New-IAMUser -UserName $adminUsername
}
Add-IAMUserToGroup -UserName $adminUsername -GroupName "Administrators"
Disable-RootSSHAccess

# 12. Configure AWS SSO and enable SSO access for the admin account
Install-Module -Name AWSPowerShellSSO -Force
Import-Module -Name AWSPowerShellSSO
Initialize-AWSSSO
$accountId = "<your_aws_account_id>"
$awsSsoRole = "AWSReservedSSO_AdministratorAccess_<your_aws_sso_instance_name>"
$awsSsoStartUrl = "https://<your_aws_sso_instance_id>.awsapps.com/start"
Add-AWSSSORoleToProfile -ProfileName "default" -RoleName $awsSsoRole -AccountId $accountId -StartUrl $awsSsoStartUrl

# 13. Configure multi-factor authentication (MFA) for the admin account
$serialNumber = "<your_mfa_serial_number>"
$accountAlias = "<your_aws_account_alias>"
Enable-IAMMFA -UserName $adminUsername -SerialNumber $serialNumber
$otp = Read-Host "Please enter the current MFA token"
$profileName = "default"
Test-IAMMFA -ProfileName $profileName -OTPCode $otp
