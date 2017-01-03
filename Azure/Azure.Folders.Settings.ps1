$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptPath\..\0-CommonInit.ps1"

$Folders = @()

$Folders += (dir $ModulesFolder | foreach FullName)
$Folders += $BakeryFolder

$Folders