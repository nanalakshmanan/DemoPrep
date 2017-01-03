function Wait-EC2State
{
    param(
        [string]
        $instanceId,

        [string]
        $desiredState
    )

    Write-Verbose "Waiting for instance $instanceid to reach state $desiredstate"

    while ($true)
    {
        $instance = Get-EC2Instance -Filter @{Name = "instance-id"; Values = $instanceid}
        $state = $instance.Instances[0].State.Name
 
        if ($state -eq $desiredstate) {
            break;
        }
 
        "$(Get-Date) Current State = $state, Waiting for Desired State=$desiredstate"
        Sleep -Seconds 5
    }
}

function Wait-EC2Status
{
    param(
        [string]
        $InstanceId
    )

    Write-Verbose "Retrieving instance $InstanceId"

    $Instance = Get-EC2Instance -Filter @{Name = "instance-id"; Values = $InstanceId}
    $publicDNS = $Instance.Instances[0].PublicDnsName
 
    #Wait for ping to succeed so we know the new VM is listening
    Write-Verbose "Pinging VM $InstanceId"

    while ($true) {
        ping $publicDNS
 
        if ($LASTEXITCODE -eq 0) {
            break
        }
 
        "$(Get-Date) Waiting for ping to succeed, sleeping 10 seconds"
        Start-Sleep -Seconds 10
    }
 
}

function Get-EC2Credential
{
    [CmdletBinding()]
    param(
        [string]
        $instanceId,

        [string]
        $KeyPairFile
    )

    $Password = Get-EC2PasswordData -InstanceId $InstanceId -PemFile $KeyPairFile -Decrypt

    $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force 

    New-Object System.Management.Automation.PSCredential "Administrator", $SecurePassword
}

function Configure-AWSVMWMF 
{
    param (
        [Parameter(Mandatory)]
        [string]$InstanceId,
        [Parameter(Mandatory)]
        [string]$KeyFilePath
    )
    Write-Verbose 'Retrieving DNS.'
    $instance = Get-EC2Instance -Filter @{Name = "instance-id"; Values = $InstanceId}
    $publicDNS = $instance.Instances[0].PublicDnsName
    Write-Verbose "Found DNS: $publicDNS"

    #Wait until the password is available
    #Blindly eats all exceptions, bad idea for a production code.
    Write-Verbose 'Retrieving password.'
    $password = $null
    while ($password -eq $null) {
        try {
            $password = Get-EC2PasswordData -InstanceId $InstanceId -PemFile $KeyFilePath -Decrypt
        }
        catch {
            "$(Get-Date) Waiting for PasswordData to be available"
            Sleep -Seconds 10
        }
    }
    Write-Verbose "Found password: $password"

    $securepassword = ConvertTo-SecureString $password -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential ('Administrator', ($securepassword))

    for($i=0; $i -lt 5; $i++)
    {
        $s = New-PSSession -ComputerName $publicDNS -Credential $creds -Verbose -ErrorAction SilentlyContinue

        if ($s -ne $null) {break;}

        Write-Verbose "Cannot create remoting session to $publicDNS, sleeping 5 seconds"
        Start-Sleep -Seconds 5
    }
    Write-Verbose "Invoking script on remote VM $publicDNS"

    try
    {
        $job = Invoke-Command -Session $s -ScriptBlock $script -Verbose
        $id = $job.Id

        Write-Verbose "waiting for job $id to complete on $publicDNS"
        Invoke-Command -Session $s -ScriptBlock {Wait-Job -Id $using:Id} 
    }
    finally
    {
        Write-Verbose "Closing remote session $($s.Id)"
        Remove-PSSession $s
    }   
    Write-Verbose "Restarting VM $publicDNS"
    Restart-Computer -ComputerName $publicDNS -Protocol WSMan -Wait -Force -Credential $creds
}

$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptPath\..\0-CommonInit.ps1"

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