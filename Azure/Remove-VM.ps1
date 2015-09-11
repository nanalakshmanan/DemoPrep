[CmdletBinding()]
param()

$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptPath\1-CommonInit.ps1" @PSBoundParameters

$VerbosePref = $false
if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $VerbosePref = $true
}

# Load configuration Settings
Write-Verbose "Loading subscription settings '$ScriptPath\Azure.Subscription.Settings.ps1'"
$Subscription = (& "$ScriptPath\Azure.Subscription.Settings.ps1")

Write-Verbose "Loading VM settings '$ScriptPath\Azure.VM.Settings.ps1'"
$VMSettings = (& "$ScriptPath\Azure.VM.Settings.ps1")

# get the relevant storage account
$StorageAccount = Get-AzureStorageAccount -ResourceGroupName $Subscription.ResourceGroup -Name $Subscription.StorageAccountName -Verbose:$VerbosePref
$Location = $Subscription.StorageLocation

foreach($VMType in $VMSettings.Keys)
{
    $Settings = $VMSettings[$VMType]
    foreach($Name in $Settings.Name)
    {
        $VMName = $Settings.BaseName + $Name
        $InterfaceName = 'Interface' + $VMName

        Write-Verbose "Removing VM $VMName"        
        Remove-AzureVM -ResourceGroupName $Subscription.ResourceGroup -Name $VMName -Force -Verbose:$VerbosePref

        Write-Verbose "Removing Network Interface $InterfaceName"
        Remove-AzureNetworkInterface -Name $InterfaceName -ResourceGroupName $Subscription.ResourceGroup -Force -Verbose:$VerbosePref

        Write-Verbose "Removing Virtual Netnwork $($Settings.VNetName)"
        $VNet = Remove-AzureVirtualNetwork -Name $Settings.VNetName -ResourceGroupName $Subscription.ResourceGroup -Force -Verbose:$VerbosePref -PassThru

        Write-Verbose "Removing Public IP Address for $InterfaceName"
        Remove-AzurePublicIpAddress -Name $InterfaceName -ResourceGroupName $Subscription.ResourceGroup -Force -Verbose:$VerbosePref
    }
}