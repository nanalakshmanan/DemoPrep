[CmdletBinding()]
param()

# Initialize all variables
$ModulesFolder = 'D:\Nana\Content\Modules'

# Get all DSC Resource Kit Modules
Find-Module -Tag dscresourcekit -Repository psgallery -OutVariable xModules

# Ensure desired directory
if (-not(Test-Path $ModulesFolder))
{
    Write-Verbose "Creating $ModulesFolder"
    md $ModulesFolder
}

# download required modules to desired directory
Write-Verbose 'Downloading modules'

Save-Module -InputObject $xModules -Path $ModulesFolder -Force -Verbose

