<#̷#̷\
#̷\ 
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\    
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#̷\  
#̷##>

$global:FullLogs = new-object System.String("")
$global:LogFilePath = new-object System.String("")
$global:LogFileName = new-object System.String("")
if((Get-Variable -Name "LogEnabled" -Scope Global -ValueOnly -ErrorAction Ignore) -eq $null){
    Set-Variable -Name "LogEnabled" -Scope Global -Value $True
}
if((Get-Variable -Name "ConsoleOutEnabled" -Scope Global -ValueOnly -ErrorAction Ignore) -eq $null){
    Set-Variable -Name "ConsoleOutEnabled" -Scope Global -Value ($env:computername -like 'maverick')
}
if((Get-Variable -Name "LogEventEnabled" -Scope Global -ValueOnly -ErrorAction Ignore) -eq $null){
    Set-Variable -Name "LogEventEnabled" -Scope Global -Value $false
}
$global:LogFileName = (new-guid).Guid
$global:LogFileName = $global:LogFileName -replace '-'
$global:LogFileName = $global:LogFileName + '.log'
[string]$TempDir=(new-guid).Guid
$TmpFilePath="$env:Temp\$TempDir"
$null=New-Item -Path $TmpFilePath -ItemType Directory -Force
$global:LogFileName = Join-Path $TmpFilePath $global:LogFileName

Enum LogLevel
{
    Verbose         =   0        
    Info            =   1
    Warning         =   2
    Error           =   3
}

Function Get-EnumValues{
    Param([string]$enum)
    # get-enumValues -enum "System.Diagnostics.Eventing.Reader.StandardEventLevel"
    
    $enumValues = @{}
    [enum]::getvalues([type]$enum) |
    ForEach-Object { 
        $enumValues.add($_, $_.value__)
    }
    $enumValues
}

function Get-TimeStamp{
    return [System.DateTime]::Now.ToString("yyyy.MM.dd hh:mm:ss");
}

Function Trace-Log {
  [CmdletBinding()]
  param(
    [Parameter(Position=0,ValueFromPipeline,ParameterSetName='Default')]
    [string]$Msg,
    [Parameter(Position=1,ValueFromPipeline,ParameterSetName='Default')] 
    [switch]$IsError,
    [Parameter(Position=2,ValueFromPipeline,ParameterSetName='Default')] 
    [ValidateSet('Verbose','Info','Warning','Error')]
    [string]$Level = 'Info'
    )

    if($Msg -eq "" -Or -not $global:LogEnabled){return}
    $global:FullLogs = $global:FullLogs + $Msg 
    if($global:ConsoleOutEnabled){
        if(-not $IsError){
            [string]$t=Get-TimeStamp
            write-host "[$Global:CurrentRunningScript] " -f DarkYellow -NoNewLine
            write-host $Msg -f DarkGray
        }
        else {
            write-host "[$Global:CurrentRunningScript] " -f DarkRed -NoNewLine
            write-host $Msg -f DarkYellow
        }
    }
    if(-not $IsError){
        [pscustomobject]@{
            Time = Get-TimeStamp
            Level = $Level
            Message = "[$Global:CurrentRunningScript] $Msg"
        } | Export-Csv -Path $global:LogFileName -Append -NoTypeInformation
    } else {
        [pscustomobject]@{
            Time = Get-TimeStamp
            Level = $Level
            Message = "[ERROR] [$Global:CurrentRunningScript] $Msg"
        } | Export-Csv -Path $global:LogFileName -Append -NoTypeInformation    
    }

}


# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSpHJhToyjyR1r3eaK4iGcGLC
# +CugggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUdsVco/yEXxKAYr/9C9N8
# O0KfDVQwDQYJKoZIhvcNAQEBBQAEggEALaZoUu93hbqKEGdCTE+AWBLptO1Hbnc3
# pFg21pfpErgCL8Qn61FHiI+D2KtdOpEU6b0JJ4YlenCwvdDMy8xrDRK7gcGBhrrn
# p5HYO1ULYJkdSOy0/LkS3zyJrzEC57uD3aVUYBwND175c/uQrGLkZKXOkJhd8HAF
# MnHfTNHLQCdKNLyPEmm2SPjawnjnxeQXgfBxtveTl2Ud+nssUAf2SepilTxzZ2cq
# gVIar5Zcc3gLY5vhJdZoFNSHCl72NQc/Uo4Gi7q2JKtOqLohfLcuGRddc2S8nOjW
# u4NMz0v23PsFjOLWMonvRdTCje3j+09iRbFNLEvaEYvUzCRKj0lBiw==
# SIG # End signature block
