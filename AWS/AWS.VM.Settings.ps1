$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

        # pick the parameter values from the Instance properties in AWS page
        # ImageId = id in parenthesis (AMI Id)
        # Keyname = name of keypair file

@{
    # each entry in this collection contains data for one type of VM
    Webserver =  @{
                        ImageId         = 'ami-4dbcb67d'
                        InstanceType    = 't2.micro'
                        KeyName         = 'NanasTestKeyPair'
                        SecurityGroup   = 'sg4'
                        MinCount        = 1
                        MaxCount        = 1
                    }            
}
