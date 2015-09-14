$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

@{
        SubscriptionName    = 'Azure Extension Test'             # Name of the subscription to use for azure cmdlets
        StorageAccountName  = 'nanapsconfdemo'                   # Azure storage account name
        StorageAccountKey   = 'FI5Irwba8oHUWswyJj4ZD5CE2t2M51/hQxA6NYBMqCrdzcnY9xaeTa6R5di75DbBf0oaBHIg/knNmgfEMbJwPw=='
        StorageLocation     = 'West US'
        StorageType         = 'Standard_GRS'
        AutomationAccount   = 'NanaDemo'
        ResourceGroup       = 'NanaDemoRG'
}
