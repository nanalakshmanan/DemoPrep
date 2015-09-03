[CmdletBinding(SupportsShouldProcess=$true)]
param()

function Ensure-Folder
{
    [CmdletBinding()]

    param(
        [string]
        $Path
    )

    if (-not (Test-Path $Path))
    {
        Write-Verbose "Creating $Path"
        md $Path > $Null
    }
}

function Get-Branch
{
    param(
        [string]
        $RepoFolder
    )

    $Branches = @()
    try
    {
        pushd $RepoFolder
        $results = (git branch)
        
        $results | % {
            if ($_.StartsWith('*'))
            {
                $Branches += ($_.Substring(1)).Trim()
            }
            else
            {
                $Branches += $_.Trim()
            }
        }
    }
    finally
    {
        popd
    }

    return $Branches
}

if ($psISE)
{
    throw 'Run this script from a PowerShell console (not ISE)'
}

$Url = 'https://api.github.com/users/nanalakshmanan/repos'
$BaseFolder = 'D:\Nana\Official\git'

Write-Verbose "Getting list of repos from $Url"

$Repos = Invoke-RestMethod -Uri $Url

Ensure-Folder $BaseFolder

try
{
    pushd $BaseFolder

    $Repos | % {

        $RepoFolder = Join-Path $BaseFolder $_.Name

        if (Test-Path $RepoFolder)
        {
            if ($PSCmdlet.ShouldProcess($_.Name, "pull changes"))
            {
                Write-Verbose "$($_.Name) exists, pulling latest changes"
                pushd $RepoFolder

                Get-Branch -RepoFolder $RepoFolder | % {
                    git pull origin $_ 2> $Null
                }
                popd
            }
        }
        else
        {
            if ($PSCmdlet.ShouldProcess($_.Name, "clone"))
            {
                Write-Verbose "$($_.Name) does not exist, cloning"
                git clone $_.clone_url
            }
        }
    }
}
finally
{
    popd
}

