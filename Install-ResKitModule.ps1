Find-Module -Repository psgallery -Tag dscresourcekit -OutVariable reskitmodules -Verbose

$reskitmodules | % {

    Write-Verbose "Module : $($_.Name)"
    $Module = $Null
    $Module = Get-InstalledModule -Name $_.Name -Verbose -ErrorAction SilentlyContinue -ErrorVariable ev 

    if ($Module -ne $Null)
    {
        Uninstall-Module -Name $_.Name -Verbose 
    }
    Install-Module -Name $_.Name -Force -Verbose -Repository psgallery
 }