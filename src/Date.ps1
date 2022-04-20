<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Get-DateString([switch]$Verbose){
<#
    .SYNOPSIS
            Get Date
    .DESCRIPTION
           Get Date
#>    

    if($Verbose){
        return ((Get-Date).GetDateTimeFormats()[8]).Replace(' ','_').ToString()
    }

    $curdate = $(get-date -Format "yyyy-MM-dd_\hhh-\mmmm-\sss")
    return $curdate 
}

function Get-DateFormat{
<#
    .SYNOPSIS
            Get Date Formats
    .DESCRIPTION
           Get Date Formats
#> 
    return (Get-Date).GetDateTimeFormats()
}


function ConvertFrom-Ctime ([Int64]$ctime) {
<#
    .SYNOPSIS
        FROM C-time converter function
    .DESCRIPTION
        Simple function to convert FROM Unix/Ctime into EPOCH / "friendly" time
#> 
    [datetime]$epoch = '1970-01-01 00:00:00'    
    [datetime]$result = $epoch.AddSeconds($Ctime)
    return $result
}


function ConvertTo-CTime ([datetime]$InputEpoch) {
<#
    .SYNOPSIS
        INTO C-time converter function
    .DESCRIPTION
        Simple function to convert into FROM EPOCH / "friendly" into Unix/Ctime, which the Inventory Service uses.
#> 
    [datetime]$Epoch = '1970-01-01 00:00:00'
    [int64]$Ctime = 0

    $Ctime = (New-TimeSpan -Start $Epoch -End $InputEpoch).TotalSeconds
    return $Ctime
}

function ConvertFrom-UnixTime{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [Int64]$UnixTime
    )
    begin {
        $epoch = [DateTime]::SpecifyKind('1970-01-01', 'Utc')
    }
    process {
        $epoch.AddSeconds($UnixTime)
    }
}

function ConvertTo-UnixTime {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [DateTime]$DateTime
    )
    begin {
        $epoch = [DateTime]::SpecifyKind('1970-01-01', 'Utc')
    }
    process {
        [Int64]($DateTime.ToUniversalTime() - $epoch).TotalSeconds
    }
}

function Get-UnixTime {
    $Now = Get-Date
    return ConvertTo-UnixTime $Now
}


# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4P+tSt7wV+96QOLvNC4E+myo
# xsmgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU5ca6nP2kYG7woBmYXx/P
# SFUiKGAwDQYJKoZIhvcNAQEBBQAEggEABk9/PCu61E33GRpdQnxY9Kda+Gvey2Wd
# i/R3m8SGKu6/NPZtUblf9ik/Qlv3r1CA3UfyDve6HsPKs8UQJxI1ttsrSJqaEm4B
# F0VOsze4yxH3O7D2WYhKPE6kIV1jkDEC3tI964ivJbphtpBInD/8gEP8tsiV4B+F
# MtKN+04t8XWtCBNC2eD6AlGF6qkjh5eRzKkhEBUkPmJnMMm5nEL+akh0vXvGCMmq
# gjYiqBs+GCVi1wksM0Tkdb/kwL44JskREcEGY9GVmAwwvjwt1XM1sqIB0Fwpc/4z
# Z3ZP0+WfNeaZWfmKSFTCMfScgvEOL3iqVln6+gxVYpzV3TNIsu9lMg==
# SIG # End signature block
