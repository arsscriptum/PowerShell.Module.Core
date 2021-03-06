<#
#ฬท๐   ๐๐ก๐ข ๐ข๐๐ก๐๐๐ฃ๐ค๐
#ฬท๐   ๐ตโโโโโ๐ดโโโโโ๐ผโโโโโ๐ชโโโโโ๐ทโโโโโ๐ธโโโโโ๐ญโโโโโ๐ชโโโโโ๐ฑโโโโโ๐ฑโโโโโ ๐ธโโโโโ๐จโโโโโ๐ทโโโโโ๐ฎโโโโโ๐ตโโโโโ๐นโโโโโ ๐งโโโโโ๐พโโโโโ ๐ฌโโโโโ๐บโโโโโ๐ฎโโโโโ๐ฑโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐บโโโโโ๐ฒโโโโโ๐ชโโโโโ๐ตโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐ณโโโโโ๐นโโโโโ๐ชโโโโโ.๐ถโโโโโ๐จโโโโโ@๐ฌโโโโโ๐ฒโโโโโ๐ฆโโโโโ๐ฎโโโโโ๐ฑโโโโโ.๐จโโโโโ๐ดโโโโโ๐ฒโโโโโ
#>

<#
    .SYNOPSIS
    Remote Desktop

#>

 
function Disable-RemoteDesktop {
    [CmdletBinding()]
    param()

    try{
        if(! $(Invoke-IsAdministrator)){ throw "You need to be admin" }
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name 'fDenyTSConnections' -Value 1
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name 'UserAuthentication' -Value 0
        Disable-NetFirewallRule -DisplayGroup "Remote Desktop"
    }catch{
        Show-ExceptionDetails $_
    }
    
}

function Enable-RemoteDesktop {
    [CmdletBinding()]
    param()
    
    try{
        if(! $(Invoke-IsAdministrator)){ throw "You need to be admin" }
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name 'fDenyTSConnections' -Value 0
        Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name 'UserAuthentication' -Value 1
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
    }catch{
        Show-ExceptionDetails $_
    }
    
}