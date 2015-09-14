$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
$WorkingFolder = 'D:\Nana\Test'
$ContentFolder = 'D:\Nana\Content\'

if ($Credential -eq $Null)
{
    $Credential = Get-Credential Administrator
}

@{
    AllNodes = @(
        @{
            NodeName = 'localhost';
            Role     = 'HyperVHost'      # HyperVHost as the role identifies
                                         # every Hyper-V host node for which
                                         # this configuration will be compiled

            # One switch can be created overall
            SwitchName        = 'DemoSwitchInternal'
            SwitchType        = 'Internal'
            SwitchIPv4Address = '92.168.1.10'

            # path where diff vhds will be created
            VhdPath         = "$WorkingFolder\Vhd"

            # path where VM data will be stored
            VMPath          = "$WorkingFolder\VM"

            # VMType is an array of hashtables
            # each entry contains data for VMs created from a single
            # vhd source

            VMType = @(             

              @{
                # name of the VMType
                Name            = 'XM-TestVM'

                # location for the source vhd
                VhdSource       = 'D:\Nana\Test\Vhd\Golden\Nana-Test.vhd'

                # VMName is an array and will be combined with namebase to 
                # create VM names like Nana-Test-DC, Nana-Test-WS, etc

                VMNameBase        = 'Nana-XM'
                VMName            = @('DC', 'Node')
                VMIPAddress       = @('92.168.1.100', '92.168.1.101')
                VMStartupMemory   = 4GB
                VMState           = 'Running'
                VMUnattendPath    = "$ScriptPath\unattend.xml"
                VMUnattendCommand = "$ScriptPath\unattend.cmd"

                # Administrator credentials
                VMAdministratorCredentials = $Credential

                # This is the modules folder. Everything under this folder
                # will be copied to $Env:ProgramFiles\WindowsPowerShell\Modules
                VMModulesFolder = (Join-Path $ContentFolder 'Modules')

                #The folders to inject into this vhd. These will be
                #available under \content
                VMFoldersToCopy = @(
                                        $ContentFolder
                                    )

              },

              @{
                # name of the VMType
                Name            = 'LTSB-TestVM'

                # location for the source vhd
                VhdSource       = 'D:\Nana\Test\Vhd\Golden\Nana-LTSB.vhd'

                # VMName is an array and will be combined with namebase to 
                # create VM names like Nana-Test-DC, Nana-Test-WS, etc

                VMNameBase        = 'Nana-V1'
                VMName            = @('Node')
                VMIPAddress       = @('92.168.1.102')
                VMStartupMemory   = 4GB
                VMState           = 'Running'
                VMUnattendPath    = "$ScriptPath\unattend.xml"
                VMUnattendCommand = "$ScriptPath\unattend.cmd"

                # Administrator credentials
                VMAdministratorCredentials = $Credential

                # This is the modules folder. Everything under this folder
                # will be copied to $Env:ProgramFiles\WindowsPowerShell\Modules
                VMModulesFolder = (Join-Path $ContentFolder 'Modules')

                #The folders to inject into this vhd. These will be
                #available under \content
                VMFoldersToCopy = @(
                                        $ContentFolder
                                    )

              }

            @{
                # name of the VMType
                Name            = 'PC-TestVM'

                # location for the source vhd
                VhdSource       = 'D:\Nana\Test\Vhd\Golden\Nana-WTR-Priv.vhd'

                # VMName is an array and will be combined with namebase to 
                # create VM names like Nana-Test-DC, Nana-Test-WS, etc

                VMNameBase        = 'Nana-PC'
                VMName            = @('Node')
                VMIPAddress       = @('92.168.1.103')
                VMStartupMemory   = 4GB
                VMState           = 'Running'
                VMUnattendPath    = "$ScriptPath\unattend.xml"
                VMUnattendCommand = "$ScriptPath\unattend.cmd"

                # Administrator credentials
                VMAdministratorCredentials = $Credential

                # This is the modules folder. Everything under this folder
                # will be copied to $Env:ProgramFiles\WindowsPowerShell\Modules
                VMModulesFolder = (Join-Path $ContentFolder 'Modules')

                #The folders to inject into this vhd. These will be
                #available under \content
                VMFoldersToCopy = @(
                                        $ContentFolder
                                    )

              }
            )
        }
    )
}