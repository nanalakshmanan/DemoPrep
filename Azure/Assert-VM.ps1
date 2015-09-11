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
        $ComputerName = $VMName
        $OSDiskName = $VMName + "OSDisk"

        Write-Verbose "Creating VM $VMName"

        # Network
        $InterfaceName = 'Interface' + $VMName
        $PublicIP = New-AzurePublicIpAddress -Name $InterfaceName `
                                             -ResourceGroupName $Subscription.ResourceGroup `
                                             -Location $Location `
                                             -AllocationMethod Dynamic `
                                             -Force `
                                             -Verbose:$VerbosePref

        $SubnetConfig = New-AzureVirtualNetworkSubnetConfig -Name $Settings.SubnetName `
                                                            -AddressPrefix $Settings.VNetSubnetAddressPrefix `
                                                            -Verbose:$VerbosePref

        $VNet = New-AzureVirtualNetwork -Name $Settings.VNetName `
                                        -ResourceGroupName $Subscription.ResourceGroup `
                                        -Location $Location `
                                        -AddressPrefix $Settings.VNetAddressPrefix `
                                        -Subnet $SubnetConfig `
                                        -Force `
                                        -Verbose:$VerbosePref `
                                        

        $Interface = New-AzureNetworkInterface -Name $InterfaceName `
                                               -ResourceGroupName $Subscription.ResourceGroup `
                                               -Location $Location `
                                               -SubnetId $VNet.Subnets[0].Id `
                                               -PublicIpAddressId $PublicIP.Id `
                                               -Force `
                                               -Verbose:$VerbosePref

        # setup local VM object
        $VirtualMachine = New-AzureVMConfig -VMName $VMName -VMSize $Settings.Size -Verbose:$VerbosePref

        $AdminCredential = New-Object System.Management.Automation.PSCredential $Settings.AdminUserName, $Settings.AdminPassword.Password 
        $VirtualMachine = Set-AzureVMOperatingSystem -VM $VirtualMachine `
                                                     -Windows `
                                                     -ComputerName $ComputerName `
                                                     -Credential $AdminCredential `
                                                     -ProvisionVMAgent `
                                                     -EnableAutoUpdate `
                                                     -Verbose:$VerbosePref
        $VirtualMachine = Set-AzureVMSourceImage -VM $VirtualMachine `
                                                 -PublisherName MicrosoftWindowsServer `
                                                 -Offer WindowsServer `
                                                 -Skus 2012-R2-DataCenter `
                                                 -Version 'latest' `
                                                 -Verbose:$VerbosePref

        $VirtualMachine = Add-AzureVMNetworkInterface -VM $VirtualMachine -Id $Interface.Id -Verbose

        $OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
        
        $VirtualMachine = Set-AzureVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption fromImage -Verbose:$VerbosePref

        # Create the new VM in Azure
        New-AzureVM -ResourceGroupName $Subscription.ResourceGroup -Location $Location -VM $VirtualMachine -Verbose:$VerbosePref

    }
}