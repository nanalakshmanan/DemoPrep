$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptPath\1-CommonInit.ps1"

Get-EC2Instance | ?{$_.Instances[0].KeyName -eq 'NanasTestKeyPair'} | Stop-EC2Instance -Terminate -Force -Verbose