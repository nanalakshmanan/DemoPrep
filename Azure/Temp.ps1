#Set basic values
$rgname = 'NanaDemoRG'
$loc = 'East US'
$vmsize = 'Standard_A2';
$vmname = 'nanaaademo11';

# Setup Storage
$stoname = 'nanapsconfdemo';
$stotype = 'Standard_GRS';

$stoaccount = Get-AzureStorageAccount -ResourceGroupName $rgname -Name $stoname;

# Create VM Object
$vm = New-AzureVMConfig -VMName $vmname -VMSize $vmsize;

# Setup Networking with a new virtual network with a single subnet
$subnet = New-AzureVirtualNetworkSubnetConfig -Name ('subnet' + $rgname) -AddressPrefix "10.0.0.0/24"
$vnet = New-AzureVirtualNetwork -Force -Name ('vnet' + $rgname) -ResourceGroupName $rgname -Location $loc -AddressPrefix "10.0.0.0/16" -DnsServer "10.1.1.1" -Subnet $subnet
$vnet = Get-AzureVirtualNetwork -Name ('vnet' + $rgname) -ResourceGroupName $rgname
$subnetId = $vnet.Subnets[0].Id

#Create a VM NIC attached to the subnet
$nic = New-AzureNetworkInterface -Force -Name ('nic' + $vmname) -ResourceGroupName $rgname -Location $loc -SubnetId $subnetId;
$nic = Get-AzureNetworkInterface -Name ('NIC' + $vmname) -ResourceGroupName $rgname;
$nicId = $nic.Id;

# Add NIC to VM
$vm = Add-AzureVMNetworkInterface -VM $vm -Id $nicId;

# Set OS disk values
$osDiskName = 'osDisk';
$osDiskCaching = 'ReadWrite';
$osDiskVhdUri = "https://$stoname.blob.core.windows.net/test/os.vhd";

# Setup OS & Image
$user = "nana";
$password = 'NL1-Test';
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force;
$cred = New-Object System.Management.Automation.PSCredential ($user, $securePassword);

$computerName = $vmname;
$vhdContainer = "https://$stoname.blob.core.windows.net/$computerName";
Get-AzureVMImage -Location 'East US' -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2012-R2-Datacenter' -Version '4.0.20150825'

#Apply the various configurations
$vm = Set-AzureVMOperatingSystem -VM $vm -Windows -ComputerName $computerName -Credential $cred;
$vm = Set-AzureVMSourceImage -VM $vm -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2012-R2-Datacenter' -Version '4.0.20150825'
$vm = Set-AzureVMOSDisk -VM $vm -VhdUri "$vhdContainer/testos.vhd" -name 'TestOS' -CreateOption fromImage

# Create Virtual Machine
New-AzureVM -ResourceGroupName $rgname -Location $loc -VM $vm;