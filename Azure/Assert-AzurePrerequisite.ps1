[CmdletBinding()]
param()

$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

$VerbosePref = $false
if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $VerbosePref = $true
}

. "$ScriptPath\1-CommonInit.ps1" @PSBoundParameters

# Load configuration Settings
Write-Verbose "Loading subscription settings '$ScriptPath\Azure.Subscription.Settings.ps1'"
$Settings = (& "$ScriptPath\Azure.Subscription.Settings.ps1")

#
# Create the storage account if it does not exist
#
if(-not (Get-AzureStorageAccount -StorageAccountName $Settings.StorageAccountName -ResourceGroup $Settings.ResourceGroup -ErrorAction SilentlyContinue))
{
    Write-Verbose "Creating new storage account $($Settings.StorageAccountName)"
    New-AzureStorageAccount -ResourceGroupName $Settings.ResourceGroup `
                            -Name $Settings.StorageAccountName `
                            -Type $Settings.StorageType `
                            -Location $Settings.StorageLocation `
                            -Verbose:$VerbosePref
}
else
{
    Write-Verbose "Storage account $($Settings.StorageAccountName) exists"
}

$Settings.StorageAccountKey = (Get-AzureStorageAccountKey -ResourceGroupName $Settings.ResourceGroup -Name $Settings.StorageAccountName  -Verbose:$VerbosePref).Key1

#
# zip and upload all the required folders
#
. "$ScriptPath\Azure.Folders.Settings.ps1" | %{
    
    . $ScriptPath\Publish-Folder.ps1 -Path $_ `
                                     -StorageAccountName $Settings.StorageAccountName `
                                     -StorageAccountKey $Settings.StorageAccountKey `
                                     -Verbose:$VerbosePref
}