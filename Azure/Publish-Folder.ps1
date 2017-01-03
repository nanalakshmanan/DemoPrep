# Simple script to zip and publish a folder to the blob
#
# This script requires that the Azure PowerShell SDK is present 
#
# Since it's the azure SDK, we need to have the connection string set in the enviornment first, which looks like
#     DefaultEndpointsProtocol=http;AccountName=$myAccountName;AccountKey=$myAccountKey
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string]
    $Path,

    [Parameter(Mandatory, Position = 1)]
    [string]
    $StorageAccountName,

    [Parameter(Mandatory, Position = 2)]
    [string]
    $StorageAccountKey
)

$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $VerbosePref = $true
}

. "$ScriptPath\1-CommonInit.ps1" -Verbose:$VerbosePref

# containername needs to be lower case in Azure
$ContainerName = (Split-Path -Path $Path -Leaf).ToLower()

#
# Create the storage container first
#
$Context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -Verbose:$VerbosePref 

if (-not(Get-AzureStorageContainer -Name $ContainerName -ErrorAction Ignore -Context $Context -ErrorVariable ev))
{
    try
    {
        New-AzureStorageContainer -Name $ContainerName -ErrorAction Stop -Context $Context -Verbose:$VerbosePref
    }
    catch
    {
        throw "Cannot create container $ContainerName in storage $StorageAccountName"
    }
}

################################################################
#
# Zip up the contents of the folder
#
################################################################

$TempModuleArchive = Join-Path ([IO.Path]::GetTempPath()) "$ContainerName.zip"
Write-Verbose -Verbose "Creating archive for $Path in $TempModuleArchive"

$null = Remove-Item -Force -Recurse -ErrorAction Ignore $TempModuleArchive

# Load the assembly containing the zip APIs
$null = Add-Type -AssemblyName System.IO.Compression.FileSystem

# And zip the module...
[void] [System.IO.Compression.ZipFile]::CreateFromDirectory($Path, $TempModuleArchive)

#
# Finally upload the zip file to a blob, replacing any existing blob
#
Write-Verbose "Uploading $Path archive from $TempModuleArchive to Azure storage: STARTED"

$Null  = Set-AzureStorageBlobContent -File $TempModuleArchive `
                                     -Container $ContainerName `
                                     -Blob "$ContainerName.zip" `
                                     -Force `
                                     -Context $Context `
                                     -Verbose:$VerbosePref 

Write-Verbose "Uploading $Path archive from $TempModuleArchive to Azure storage: COMPLETE"
