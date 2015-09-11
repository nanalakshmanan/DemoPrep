$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

@{
        SubscriptionName    = 'Azure Extension Test'             # Name of the subscription to use for azure cmdlets
        StorageAccountName  = 'nanapsconfdemo'                   # Azure storage account name
        StorageAccountKey   = 'FI5Irwba8oHUWswyJj4ZD5CE2t2M51/hQxA6NYBMqCrdzcnY9xaeTa6R5di75DbBf0oaBHIg/knNmgfEMbJwPw=='
        StorageLocation     = 'West US'
        StorageType         = 'Standard_GRS'
        AutomationAccount   = 'NanaDemo'
        ResourceGroup       = 'NanaDemoRG'
        #PublishSettingsFile = "$ScriptPath\..\Settings\Visual Studio Ultimate with MSDN-5-8-2014-credentials.publishsettings"
        #ImageName           = 'a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201403.01-en.us-127GB.vhd'
        #CloudServer         = 'blob.core.windows.net'
}
