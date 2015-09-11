if ($Credential -eq $Null)
{
    Get-Credential Administrator
}

@{
    DemoNode = @{

            BaseName                = 'nana-aademo'
            Name                    = @('100')
            Size                    = 'Standard_A2'
            SubnetName              = 'Nana-Subnet'
            VNetName                = 'NanaDemoVNet'
            VNetAddressPrefix       = "10.0.0.0/16"
            VNetSubnetAddressPrefix = "10.0.0.0/24"
            AdminUserName           = 'nana'           
            AdminPassword           = $Credential
            
    }
}