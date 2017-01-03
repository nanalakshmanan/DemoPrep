[CmdletBinding()]
param()

if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $VerbosePref = $true
}

Find-Module -Repository psgallery -Tag dscresourcekit -OutVariable reskitmodules -Verbose:$VerbosePref

$reskitmodules | % {

    Write-Verbose "Module : $($_.Name)"
    $Module = $Null
    $Module = Get-InstalledModule -Name $_.Name -Verbose:$VerbosePref -ErrorAction SilentlyContinue -ErrorVariable ev 

    if ($Module -ne $Null)
    {
        Uninstall-Module -Name $_.Name -Verbose:$VerbosePref 
    }
    Install-Module -Name $_.Name -Force -Verbose:$VerbosePref -Repository psgallery
 }