[CmdletBinding()]
param()

$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptPath\1-CommonInit.ps1"

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

$InstanceIds = @()
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

    # workaround to ensure Instances property is available
    Sleep 5
    $VMInstances += $instance
    $InstanceIds += $instance.Instances[0].InstanceId
}

$InstanceIds | % {
    Wait-EC2State -instanceId $_ -desiredState running
}

$InstanceIds | % {
    Wait-EC2Status -InstanceId $_
}

# install WMF
. "$ScriptPath\..\Install-WMF.ps1"
$InstanceIds | % {
    Configure-AWSVMWMF -InstanceId $_ -KeyFilePath $KeyFilePath
}