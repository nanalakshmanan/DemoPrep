$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

@{
        CredentialsFile     = 'C:\Nana\AWS\AccessKeys.csv'
        DefaultRegion       = 'us-west-2'
}
