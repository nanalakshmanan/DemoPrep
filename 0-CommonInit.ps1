
$MyPath = Split-Path $MyInvocation.MyCommand.Path
$AWSPath = 'D:\Nana\Official\AWS'
$ModulesFolder = 'D:\Nana\Content\Modules'
$BakeryFolder = 'D:\Nana\Content\BakeryWebsite'
$KeyFilePath = 'D:\Nana\Official\AWS\NanasTestKeyPair.pem'
#endregion Initialization

. "$MyPath\Install-WMF.ps1"