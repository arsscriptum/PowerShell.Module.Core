<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



function SecUtilException{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.ErrorRecord]$Record,
        [Parameter(Mandatory=$false)]
        [switch]$ShowStack
    )       
    $formatstring = "{0}`n{1}"
    $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
    $ExceptMsg=($formatstring -f $fields)
    $Stack=$Record.ScriptStackTrace
    Write-Host "[security util exception] -> " -NoNewLine -ForegroundColor Red; 
    Write-Host "$ExceptMsg" -ForegroundColor Yellow
    if($ShowStack){
        Write-Host "--stack begin--" -ForegroundColor Green
        Write-Host "$Stack" -ForegroundColor Gray  
        Write-Host "--stack end--`n" -ForegroundColor Green       
    }
}   



function Confirm-IsAdministrator  
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    if((New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) ){
        return $true
    }
    return $false
}

function Set-ExclusionPaths  
{  
    $ExclusionPath = @()
    $ExclusionPath += 'c:\Scripts'
    $ExclusionPath += 'c:\Data'
    $ExclusionPath += 'c:\DOCUMENTS'
    ForEach($p in $ExclusionPath){
        Write-Host "Add path to excluded path list: $p" -f White
        Add-MpPreference -ExclusionPath $p
    }
}

function Disable-RealTimeProtection{

    [CmdletBinding(SupportsShouldProcess)]
    Param()   
    try{
        if(-not(Confirm-IsAdministrator)) { throw "Must be Administrator" ; return }

        <#̷#̷\
        #̷\   𝓡𝓣𝓟𝓻𝓸𝓽𝓮𝓬𝓽𝓲𝓸𝓷 𝓫𝓸𝓽𝓱𝓮𝓻𝓼 𝓶𝓮 𝔀𝓲𝓽𝓱 𝓪𝓵𝓵 𝓽𝓱𝓮 𝓹𝓸𝓹𝓾𝓹𝓼, 𝓹𝓵𝓾𝓼 𝓘 𝓱𝓪𝓿𝓮 𝓹𝓵𝓮𝓷𝓽𝔂 𝓸𝓯 𝓼𝓬𝓻𝓲𝓹𝓽𝓼 𝓽𝓸 𝓬𝓸𝓹𝔂
        #̷##>
        Write-Host "Disable-RealTimeProtection" -f White
        Write-Host " ==> LocalSettingOverrideDisableBehaviorMonitoring" -f DarkGray
        Write-Host " ==> LocalSettingOverrideDisableIntrusionPreventionSystem" -f DarkGray
        Write-Host " ==> LocalSettingOverrideDisableRealtimeMonitoring" -f DarkGray       
        Write-Host " ==> DisableAntiSpyware" -f Red       
        $null=New-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "LocalSettingOverrideDisableBehaviorMonitoring" 1 DWORD
        $null=New-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "LocalSettingOverrideDisableIntrusionPreventionSystem" 1 DWORD
        $null=New-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "LocalSettingOverrideDisableRealtimeMonitoring" 1 DWORD
        $null=New-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" "DisableAntiSpyware" 1 DWORD
    }catch{
        SecUtilException($_) -ShowStack
    }
}

function Disable-ExploitGuard{

    [CmdletBinding(SupportsShouldProcess)]
    Param()   
    try{
        if(-not(Confirm-IsAdministrator)) { throw "Must be Administrator" ; return }

        <#̷#̷\
        #̷\   𝓑𝓮𝓬𝓪𝓾𝓼𝓮 𝓘 𝓛𝓞𝓥𝓔 𝓔𝔁𝓹𝓵𝓸𝓲𝓽𝓼 :)
        #̷##>
        Write-Host "Disable-SmartScreen" -f White
        Write-Host " ==> EnableNetworkProtection" -f DarkGray
        Write-Host " ==> ExploitGuard_ASR_Rules" -f DarkGray
        Write-Host " ==> DisableIOAVProtection" -f DarkGray
        $null=New-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection" "EnableNetworkProtection" 0 DWORD
        $null=New-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR" "ExploitGuard_ASR_Rules" 0 DWORD
        $null=New-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableIOAVProtection" 1 DWORD

    }catch{
        SecUtilException($_) -ShowStack
    }

}
function Disable-SmartScreen{
    # Define Parameters
    [CmdletBinding(SupportsShouldProcess)]
    Param()
    try{
        if(-not(Confirm-IsAdministrator)) { throw "Must be Administrator" ; return }

        Write-Host "Disable-SmartScreen" -f White
        Write-Host " ==> EnableSmartScreen" -f DarkGray
        Write-Host " ==> ShellSmartScreenLevel" -f DarkGray
        <#̷#̷\
        #̷\   𝓓𝓲𝓼𝓪𝓫𝓵𝓮 𝓼𝓶𝓪𝓻𝓽-𝓼𝓬𝓻𝓮𝓮𝓷 𝓭𝓮𝓽𝓮𝓬𝓽𝓲𝓸𝓷 𝓸𝓯 𝓶𝓪𝓵𝔀𝓪𝓻𝓮
        #̷##>
        $null=New-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen" 0 DWORD
        $null=New-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "ShellSmartScreenLevel" "Warn" String

    }catch{
        SecUtilException($_) -ShowStack
    }
}

function Disable-SecurityFeatures{
    # Define Parameters
    [CmdletBinding(SupportsShouldProcess)]
    Param()  
    Disable-SmartScreen -Verbose:$Verbose -WhatIf:$WhatIf
    Disable-ExploitGuard -Verbose:$Verbose -WhatIf:$WhatIf
    Disable-RealTimeProtection -Verbose:$Verbose -WhatIf:$WhatIf
}
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfiHW5tLpmiTsulYAB4Ow9hxJ
# DOGgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0yMjAyMDkyMzI4NDRaFw0zOTEyMzEyMzU5NTlaMCUxIzAhBgNVBAMTGkFyc1Nj
# cmlwdHVtIFBvd2VyU2hlbGwgQ1NDMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
# CgKCAQEA60ec8x1ehhllMQ4t+AX05JLoCa90P7LIqhn6Zcqr+kvLSYYp3sOJ3oVy
# hv0wUFZUIAJIahv5lS1aSY39CCNN+w47aKGI9uLTDmw22JmsanE9w4vrqKLwqp2K
# +jPn2tj5OFVilNbikqpbH5bbUINnKCDRPnBld1D+xoQs/iGKod3xhYuIdYze2Edr
# 5WWTKvTIEqcEobsuT/VlfglPxJW4MbHXRn16jS+KN3EFNHgKp4e1Px0bhVQvIb9V
# 3ODwC2drbaJ+f5PXkD1lX28VCQDhoAOjr02HUuipVedhjubfCmM33+LRoD7u6aEl
# KUUnbOnC3gVVIGcCXWsrgyvyjqM2WQIDAQABo3YwdDATBgNVHSUEDDAKBggrBgEF
# BQcDAzBdBgNVHQEEVjBUgBD8gBzCH4SdVIksYQ0DovzKoS4wLDEqMCgGA1UEAxMh
# UG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZpY2F0ZSBSb290ghABvvi0sAAYvk29NHWg
# Q1DUMAkGBSsOAwIdBQADggEBAI8+KceC8Pk+lL3s/ZY1v1ZO6jj9cKMYlMJqT0yT
# 3WEXZdb7MJ5gkDrWw1FoTg0pqz7m8l6RSWL74sFDeAUaOQEi/axV13vJ12sQm6Me
# 3QZHiiPzr/pSQ98qcDp9jR8iZorHZ5163TZue1cW8ZawZRhhtHJfD0Sy64kcmNN/
# 56TCroA75XdrSGjjg+gGevg0LoZg2jpYYhLipOFpWzAJqk/zt0K9xHRuoBUpvCze
# yrR9MljczZV0NWl3oVDu+pNQx1ALBt9h8YpikYHYrl8R5xt3rh9BuonabUZsTaw+
# xzzT9U9JMxNv05QeJHCgdCN3lobObv0IA6e/xTHkdlXTsdgxggHhMIIB3QIBATBA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdAIQ
# mkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUtM6Wxh+X4RGZariUNvT9
# jc5enH8wDQYJKoZIhvcNAQEBBQAEggEAl7QLuCSxNlwwy/rraFdFM4f21ne4pG/1
# u18CsgKPYMioVQSSjNeBVvXdQkosFcDPO2l/G/VmPBF6AaKmYFptL1uOaDQ27vNS
# yDVjUArDmV0V29tct6oHUycdQmgYIb5jTOpBjT7i2mYMDF8769EP7efS7mOVpYPS
# 6Oqbc4oD/2ZSE+kvGPeizTfTnyIpMX8+JG358dW7bWTHcFCjSXcQTEM6SHPhY+7R
# Uyp1sQ3e/Urgzh1jO5dtPfo1OGcQNW+Sxyys8LHEGKeWqu2l9v7YhsC8fIKKIlMG
# w3tewb6eq/k5sjeDajK0gLR6iFdreUsLkS8OkUeHl0Saw1Qg9PfTdA==
# SIG # End signature block
