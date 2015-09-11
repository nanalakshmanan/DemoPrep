$VerbosePreference = "continue"
$ErrorActionPreference = 'stop'
Set-StrictMode -Version latest

$script = { 
    $job = {
        $WMFVersion = '5.0'

        # WMF download links and IDs
        $script:wmfDownloadInfo = @{
            #
            # ********************************************** WMF 4.0 **********************************************
            #
            # Server 2008 R2 SP1 or Windows 7 SP1
            #
            'WMF_4.0-Windows_6.1-x64' = @{ 
                HotfixId = 'KB2819745'
                Url = 'http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu'
                RequiresDotNet4_5 = $true
            }
            'WMF_4.0-Windows_6.1-x86' = @{ 
                HotfixId = 'KB2819745'
                Url = 'http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x86-MultiPkg.msu'
                RequiresDotNet4_5 = $true
            }
            #
            # Server 2012 (no support for x86)
            #
            'WMF_4.0-Windows_6.2-x64' = @{ 
                HotfixId = 'KB2799888'
                Url = 'http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows8-RT-KB2799888-x64.msu'
            }
            #
            # ********************************************** KB3000850 *********************************************
            #
            # Server 2012 R2 or Windows 8.1
            #
            'WMF_4.0-Windows_6.3-x64' = @{ 
                HotfixId = 'KB3000850'
                Url = 'http://download.microsoft.com/download/9/1/7/91772932-6DA4-48FD-9B1F-DA2C7EAEE35B/Windows8.1-KB3000850-x64.msu'
            }
            'WMF_4.0-Windows_6.3-x86' = @{ 
                HotfixId = 'KB3000850'
                Url = 'http://download.microsoft.com/download/A/5/1/A51119A7-729B-4800-844C-189E2BDCFF85/Windows8.1-KB3000850-x86.msu'
            }
            #
            # ********************************************** WMF 5.0 **********************************************
            #
            # Server 2012 R2 or Windows 8.1
            #
            # Production Preview
            #
            'WMF_5.0-Windows_6.3-x64' = @{ 
                HotfixId = 'KB3066437'
                Url = 'http://download.microsoft.com/download/3/F/D/3FD04B49-26F9-4D9A-8C34-4533B9D5B020/Win8.1AndW2K12R2-KB3066437-x64.msu'
            }
            'WMF_5.0-Windows_6.3-x86' = @{ 
                HotfixId = 'KB3066437'
                Url = 'http://download.microsoft.com/download/3/F/D/3FD04B49-26F9-4D9A-8C34-4533B9D5B020/Win8.1AndW2K12R2-KB3066437-x86.msu'
            }
            #
            # Server 2012 (no support for x86)
            #
            # April Preview
            #
            'WMF_5.0-Windows_6.2-x64' = @{ 
                HotfixId = 'KB3066438'
                Url = 'http://download.microsoft.com/download/3/F/D/3FD04B49-26F9-4D9A-8C34-4533B9D5B020/W2K12-KB3066438-x64.msu'
            }
            #
            # Server 2008 R2 SP1 
            #
            # April Preview
            #
            'WMF_5.0-Windows_6.1-x64' = @{ 
                HotfixId = 'KB3066439'
                Url = 'http://download.microsoft.com/download/3/F/D/3FD04B49-26F9-4D9A-8C34-4533B9D5B020/Win7AndW2K8R2-KB3066439-x64.msu'
                RequiresWmf4 = $true
            }
            'WMF_5.0-Windows_6.1-x86' = @{ 
                HotfixId = 'KB3066439'
                Url = 'http://download.microsoft.com/download/3/F/D/3FD04B49-26F9-4D9A-8C34-4533B9D5B020/Win7AndW2K8R2-KB3066439-x86.msu'
                RequiresWmf4 = $true
            }

            #
            # ********************************************** Windows Server 2016 **********************************************
            #
            #
            # Server 2016 Technical Preview 3
            #
            'WMF_4.0-Windows_10.0-x64' = @{
                SkipWmfInstall = $true
            }
           'WMF_4.0-Windows_10.0-x86' = @{
                SkipWmfInstall = $true
            }
            #
            # Server 2016 Technical Preview 3
            #
            'WMF_5.0-Windows_10.0-x64' = @{
                SkipWmfInstall = $true
            }
            'WMF_5.0-Windows_10.0-x86' = @{
                SkipWmfInstall = $true
            }
        }

        # Download URL for .NET 4.5
        $dotNet4_5Url = 'http://download.microsoft.com/download/B/A/4/BA4A7E71-2906-4B2D-A0E1-80CF16844F5F/dotNetFx45_Full_setup.exe'

        <#
        .Synopsis
           Tests whether the given hotfix is installed
        #>
        function Test-Hotfix {
            [CmdletBinding()]
            [OutputType([bool])]
            param(
                [Parameter(Mandatory=$true,Position = 0)]
                    [string] $HotfixId
            )

            [bool](Get-Hotfix -Id $HotfixId -ErrorAction SilentlyContinue)
        }

        <#
        .synopsys
            Installs WMF

        .remarks
            Returns the ID of the hotfix that was installed
        #>
        function Install-Wmf {
            param(
                [parameter(mandatory=$true)]
                [Hashtable] $DownloadInfo
            )

            if ($DownloadInfo['RequiresWmf4']) {
                Write-Host ('WMF ({0}) requires WMF 4.0...' -f $DownloadInfo.HotfixId)

                $wmf4DownloadInfo = Get-WmfDownloadInfo -WmfVersion '4.0'

                Write-Host ('Verifying that WMF 4.0 ({0}) is installed...' -f $wmf4DownloadInfo.HotfixId)

                if (Test-Hotfix $wmf4DownloadInfo.HotfixId)
                {
                    Write-Host 'WMF 4.0 is already installed.'
                }
                else
                {
                    Write-Host ('Installing WMF 4.0 ({0})...' -f $wmf4DownloadInfo.HotfixId)

                    Install-Wmf $wmf4DownloadInfo

                    return $wmf4DownloadInfo.HotfixId
                }
            }

            if ($downloadInfo['RequiresDotNet4_5'] -and !(Test-DotNet4_5))
            {
                Write-Host 'WMF requires .NET 4.5; installing...'

                Install-DotNet4_5
            }

            Write-Host ('Installing WMF ({0})...' -f $downloadInfo.HotfixId)

            Install-Hotfix -Url $downloadInfo.Url -HotfixId $downloadInfo.HotfixId

            return $downloadInfo.HotfixId
        }

        # Installs .NET 4.5
        function Install-DotNet4_5 {
            Write-Host 'Installing .NET 4.5 ...'
    
            $downloadedFile = Download -Url $dotNet4_5Url

            $logFile = $downloadedFile + ".log"

            Write-Host "Installing $downloadedFile..."

            $process = [System.Diagnostics.Process]::Start($downloadedFile, "/q /norestart /log $logFile")

            if (!$process.WaitForExit(60 * 60 * 1000)) { # wait for 60 min
                throw 'Installing .NET 4.5 timed out; exiting...'
            }
        }

        # Returns a hashtable with these items:
        #    Version  - A System.Version object with the version of the current OS
        #    IsServer - True if the current OS is a server SKU
        #    IsX64    - True if the current architecture is 64-bit
        function GetOSVersion {
            $os = Get-WmiObject Win32_OperatingSystem
            $processor = Get-WmiObject Win32_Processor

            # On PS/.NET 2.0, [System.Version] doesn't have a Parse method 
            if (!($os.Version -match '^(?<major>[0-9]+)\.(?<minor>[0-9]+)(\.[0-9]+)*$')) {
                throw "Invalid OS version: $($os.Version)"
            }

            @{
                Version  = ('{0}.{1}' -f [int]::Parse($matches['major']), [int]::Parse($matches['minor']))
                IsServer = $os.ProductType -ne 1 # 1 == Workstation
                IsX64    = $processor.AddressWidth -eq 64
            }
        }

        <#
        .Synopsis
            Installs the given hotfix
        #>
        function Install-Hotfix {
            param(
                [Parameter(Mandatory=$true)]
                    [string] $Url,
                [Parameter(Mandatory=$true)]
                    [string] $HotfixId
            )

            $downloadedFile = Download -Url $Url

            $logFile = $downloadedFile + ".log"
            function InvokeWusa {
                Write-Host "Installing $downloadedFile..."

                $process = [System.Diagnostics.Process]::Start('wusa.exe', "/quiet /norestart /log:$logFile $downloadedFile")

                if (!$process.WaitForExit(60 * 60 * 1000)) { # wait for 60 min
                    throw "Installing $HotfixId timed out; exiting..."
                }

                Write-Host "Install completed (wusa.exe exit code: $($process.ExitCode))"

                return $process
            }

            $process = InvokeWusa

            #
            # 0x8024800c ("The data store section could not be locked within the allotted time") may indicate a conflict with
            # Windows Update, so we stop the service and try one more time.
            #
            $windowsUpdate = 'Windows Update'

            if ($process.ExitCode -eq 0x8024800c -and ((Get-Service $windowsUpdate).Status -eq 'Running')) {
                Write-Host 'Install had a conflict with Windows Update; will retry.'
                Write-Host 'Stopping Windows Update service...'
                Stop-Service $windowsUpdate -Force -Verbose
                try {
                    InvokeWusa > $null
                }
                finally {
                    Write-Host 'Restarting Windows Update service...'
                    Start-Service $windowsUpdate -ErrorAction Continue -Verbose
                }
            }
        }

        <#
        .Synopsis

            Returns the download info for WMF, which is a hashtable with these items:

                HotfixId - Name of the WMF hotfix 
                Url      - Url of the WMF hotfix 
        #>
        function Get-WmfDownloadInfo {
                        param(
            [Parameter(Mandatory)]
            [string] $WmfVersion
        )

            $osVersion = GetOSVersion

            if ($osVersion.IsX64) {
                $arch = 'x64'
            } else {
                $arch = 'x86'
            }

            $key = 'WMF_{0}-Windows_{1}-{2}' -f $WmfVersion, $osVersion.Version, $arch

            Write-Host "WMF key: $key"

            $downloadInfo = $script:wmfDownloadInfo[$key]

            if (!$downloadInfo)
            {
                throw New-HandlerTerminatingError $DSC_Status.OsVersionNotSupported
            }

            $downloadInfo
        }

        # Downloads the given URL to a local file and outputs the path to the file
        function Download {
            param([Parameter(Mandatory=$true)][string] $Url)

            $webClient = $null

            try 
            {
                $uri = [URI] $url

                $update = $uri.Segments[$uri.Segments.Count - 1]
        
                $localFile = '{0}\{1}' -f $DSC_MainWorkingFolder, $update

                #if (Test-Path $localFile) {
                #    throw New-HandlerTerminatingError `
                #        -Code $DSC_Status.WmfInstallError.Code `
                #        -Message ($DSC_Status.WmfInstallError.Message -f $update, (GetLogDirectory))
                #}

                $webClient = New-Object System.Net.WebClient

                for ($i = 0; $true; $i++) {
                    try {
                        Write-Host "Downloading $Url ..."
    
                        $webClient.DownloadFile($Url, $localFile)
                
                        break
                    }
                    catch {
                        if ($i -lt 6) {
                            Write-Host "Download Error: $_"
                            Write-Host 'Will retry after a short delay'
                            Start-Sleep -Seconds 15
                        } else {
                            throw $_
                        }
                    }
                }

                $localFile

            }
            finally
            {
                if ($webClient) {
                    $webClient.Dispose()
                }
            }
        }

    
        # Install WMF if the machine doesn't have the correct version.
        $downloadInfo = Get-WmfDownloadInfo -WmfVersion $WMFVersion

        Write-Host "Inside the script."
        if (!$downloadInfo['SkipWmfInstall']) {
            Write-Host ('Verifying that WMF ({0}) is installed...' -f $downloadInfo.HotfixId)

            if (Test-Hotfix $downloadInfo.HotfixId)
            {
                Write-Host 'WMF is already installed.'
            }
            else
            {
                return Install-Wmf $downloadInfo
            }
        }
    }

    # Trigger
    $oneTimeTrigger = New-JobTrigger -once -At (Get-Date -Minute ($currentDate.Minute + 1))

    Register-ScheduledJob -Name InstallWMF2 -ScriptBlock $job -RunNow
}


