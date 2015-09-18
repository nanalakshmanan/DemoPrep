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
# Create the resource group if it does not exist
#
if (-not (Get-AzureResourceGroup -Name $Settings.ResourceGroup -ErrorAction SilentlyContinue))
{
    Write-Verbose "Creating new resource group $($Settings.ResourceGroup)"
    New-AzureResourceGroup -Name $settings.ResourceGroup `
                           -Location $Settings.StorageLocation `
                           -Force `
                           -Verbose:$VerbosePref
}
else
{
    Write-Verbose "Resource group $($Settings.ResourceGroup) exists"
}

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
# Create the automation account if it does not exist
#
if (-not (Get-AzureAutomationAccount -ResourceGroupName $Settings.ResourceGroup -Name $Settings.AutomationAccount -ErrorAction SilentlyContinue))
{
    Write-Verbose "Creating automation account $($Settings.AutomationAccount)"
    New-AzureAutomationAccount -ResourceGroupName $Settings.ResourceGroup `
                               -Name $Settings.AutomationAccount `
                               -Location $Settings.StorageLocation `
                               -Verbose:$VerbosePref
}
else
{
    Write-Verbose "Automation account $($Settings.AutomationAccount) exists"
}

#
# zip and upload all the required folders
#
. "$ScriptPath\Azure.Folders.Settings.ps1" | %{
    
    . $ScriptPath\Publish-Folder.ps1 -Path $_ `
                                     -StorageAccountName $Settings.StorageAccountName `
                                     -StorageAccountKey $Settings.StorageAccountKey `
                                     -Verbose:$VerbosePref
}