[CmdletBinding()]
param()

$CommonInit1Path = Split-Path $MyInvocation.MyCommand.Path
. "$CommonInit1Path\..\0-CommonInit.ps1"

$VerbosePref = $false
if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $VerbosePref = $true
}

Import-Module -Name Azure -Verbose:$false -ErrorVariable ev -ErrorAction SilentlyContinue 

if ($ev -ne $null)
{
    Import-Module -Name AzureResourceManager -Verbose:$false -ErrorVariable ev -ErrorAction Stop 
}

Switch-AzureMode -Name AzureResourceManager

#

if (-not(Get-AzureAccount -ErrorAction SilentlyContinue))
{
    Add-AzureAccount -ErrorVariable ev

    if ($ev -ne $Null)
    {
        throw 'Something went wrong in Azure authentication, try again'
    }
}
