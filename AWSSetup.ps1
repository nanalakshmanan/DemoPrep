[CmdletBinding()]
param()

$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptPath\0-CommonInit.ps1"

Write-Verbose "Loading subscription settings file $ScriptPath\AWS.Subscription.Settings.ps1"
$Settings = (& "$ScriptPath\AWS.Subscription.Settings.ps1")

Write-Verbose "Loading VM settings file $ScriptPath\AWS.VM.Settings.ps1"
$VMSettings = (& "$ScriptPath\AWS.VM.Settings.ps1")

# this is the CSV file generat by "Created Access Key in AWS IAM"
$AWSKeys = Import-Csv -Path $Settings.CredentialsFile
Write-Verbose "Setting AWS credentials from file $($Settings.CredentialsFile)"
Set-AWSCredentials -AccessKey $AWSKeys.'Access Key Id' -SecretKey $AWSKeys.'Secret Access Key'

# set the default region
Write-Verbose "Setting default AWS region to $($Settings.DefaultRegion)"
Set-DefaultAWSRegion -Region $Settings.DefaultRegion -Verbose

# PowerShell script to run on initializing EC2 instance
$userdata = @"
<powershell>
Set-NetFirewallRule -Name WINRM-HTTP-In-TCP-PUBLIC -RemoteAddress Any
Enable-NetFirewallRule FPS-ICMP4-ERQ-In
</powershell>
"@

Write-Verbose "Will inject following code to set up firewall rules $userdata"

#Userdata has to be base64 encoded
$userdataBase64Encoded = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($userdata))
$VMInstances = @()

foreach($VMType in $VMSettings.Keys)
{
    $Config = $VMSettings[$VMType]

    Write-Verbose "Creating new EC2 instance with ImageId = $($Config.ImageId), InstanceType = $($Config.InstanceType), KeyName = $($Config.KeyName), SecurityGroup = $($Config.SecurityGroup), MinCount = $($Config.MinCount), MaxCount = $($Config.MaxCount)"

    $instance = New-EC2Instance -ImageId       $Config.ImageId  `
                                -InstanceType  $config.InstanceType`
                                -KeyName       $config.KeyName`
                                -SecurityGroup $config.SecurityGroup`
                                -MinCount      $config.MinCount `
                                -MaxCount      $config.MaxCount `
                                -UserData      $userdataBase64Encoded `
                                -Verbose

    $VMInstances += $instance

}

while($true)
{    
    [array]$InitInstances = (Get-EC2Instance -Instance $VMInstances | foreach Instances | ?{$_.State.Name -ne 'Running'} | ?{$_.State.Name -ne 'Terminated'})

    if ($InitInstances.Count -eq 0)
    {
        break
    }

    Write-Verbose "$($InitInstances.Count) VMs are being initialized, sleeping for 5 seconds"
    Start-Sleep -Seconds 5
}
