Get-VM | Stop-VM -Passthru | Remove-VM -Force
rd -Recurse -Force D:\Nana\Test\Vhd\Instance 2> $Null
rd -Recurse -Force D:\Nana\Test\VM 2> $Null
rd -Recurse -Force D:\Nana\Test\CompiledConfigurations 2> $Null

del D:\Nana\Test\Vhd\Base\Nana-XM.Base.Vhd 2> $Null
del D:\Nana\Test\Vhd\Base\Nana-PC.Base.Vhd 2> $Null
del D:\Nana\Test\Vhd\Base\Nana-LTSB.Base.Vhd 2> $Null
