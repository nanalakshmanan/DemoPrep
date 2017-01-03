$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
$ConfigData = (& "$ScriptPath\Assert-VM-Data.ps1")
$WorkingFolder = 'D:\Nana\Test'

Import-Module "$Env:ProgramFiles\WindowsPowerShell\Modules\TestSetup\DSCResources\TestMachine" -Force

Remove-Item -Recurse -Force "$WorkingFolder\CompiledConfigurations\TestMachine" -ErrorAction Ignore 2> $null
TestMachine -OutputPath "$WorkingFolder\CompiledConfigurations\TestMachine" -ConfigurationData $ConfigData

Start-DscConfiguration -Wait -Force -Path "$WorkingFolder\CompiledConfigurations\TestMachine" -Verbose

# create VM snapshots
Get-VM | Checkpoint-VM -SnapshotName 'Initial' -Passthru -Verbose