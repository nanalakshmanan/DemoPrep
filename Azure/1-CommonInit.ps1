[CmdletBinding()]
param()

$CommonInit1Path = Split-Path $MyInvocation.MyCommand.Path
. "$CommonInit1Path\..\0-CommonInit.ps1"

$VerbosePref = $false
if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $VerbosePref = $true
}

Import-Module -Name AzureRM.Profile -Verbose:$false -ErrorVariable ev -ErrorAction SilentlyContinue 

if (-not(Get-AzureRmSubscription -ErrorAction SilentlyContinue))
{
    Add-AzureRmAccount -ErrorVariable ev

    if ($ev -ne $Null)
    {
        throw 'Something went wrong in Azure authentication, try again'
    }
}
