pushd $env:windir\system32\configuration
del *.mof
cd PartialConfigurations
del *.mof
cd ..\ConfigurationStatus
del *.mof
popd
