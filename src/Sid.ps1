<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   Sid
#̷𝓍   
#̷𝓍   <guillaumeplante.qc@gmail.com>
#̷𝓍   https://arsscriptum.github.io/
#>



function Convert-SIDtoName([String[]] $SIDs, [bool] $OnErrorReturnSID) {
    foreach ($sid in $SIDs) {
        try {
            $objSID = New-Object System.Security.Principal.SecurityIdentifier($sid) 
            $objUser = $objSID.Translate([System.Security.Principal.NTAccount]) 
            $objUser.Value
        } catch { if ($OnErrorReturnSID) { $sid } else { "" } }
    }
}

function Get-SIDUSerTable {
    [CmdletBinding(SupportsShouldProcess)]
    param ()  
    $WmicExe = (get-command wmic).Source  
    [array]$UsersSIDs=&"$WmicExe" "useraccount" "get" "name,sid"
    $UsersSIDsLen = $UsersSIDs.Length
    $SidIndex = $UsersSIDs[0].IndexOf('SID')
    $UserTable = [System.Collections.ArrayList]::new()
    For($i = 1 ; $i -lt $UsersSIDsLen ; $i++){
        $Len = $UsersSIDs[$i].Length
        if($Len -eq 0) { continue }
        $username = $UsersSIDs[$i].SubString(0,$SidIndex)
        $username = $username.trim()
        $sid = $UsersSIDs[$i].SubString($SidIndex)
        $res = [PSCustomObject]@{
                Username            = $username
                SID                 = $sid
        }
        $UserTable.Add($res)
    }
    return $UserTable
}

function Get-SIDValueForUSer {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$Username
    )
    $WmicExe = (get-command wmic).Source  
    [array]$UsersSIDs=&"$WmicExe" "useraccount" "get" "name,sid"
    $UsersSIDsLen = $UsersSIDs.Length
    $SidIndex = $UsersSIDs[0].IndexOf('SID')
    
    For($i = 1 ; $i -lt $UsersSIDsLen ; $i++){
        $Len = $UsersSIDs[$i].Length
        if($Len -eq 0) { continue }
        $usr = $UsersSIDs[$i].SubString(0,$SidIndex)
        $usr = $usr.trim()
        $sid = $UsersSIDs[$i].SubString($SidIndex)
        $sid = $sid.trim()
        $res = [PSCustomObject]@{
                Username            = $usr
                SID                 = $sid
        }
        if($Username -eq $usr){
            return $res
        }
    }
   
    return $null
}

function Get-USerSID
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$Username
    )
    
    try {
        $sid = Get-SIDValueForUSer $Username
        return $sid
    }
    catch {
        Write-Host '[Get-USerSID] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}

function Get-UserNtAccount
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$Username
    )
    
    try {
        $sid = (Get-USerSID $Username).SID
        $value = (Convert-SIDtoName $sid)
        $obj = $(new-object security.principal.ntaccount "$value")
        [System.Security.Principal.IdentityReference]$Principal = $(new-object security.principal.ntaccount "$value")
        return $Principal
       
    }
    catch {
        Write-Host '[Get-USerSID] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUA+XRwBoIDSymGvVehwZNIwdj
# MoegggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUvWuU1nQgwu6tFLdnzeHB
# cYpmp3AwDQYJKoZIhvcNAQEBBQAEggEAJ9stS17DI2P81MFK0kJvLyjq0LPxdUzW
# 1HEH0AGHRcrnk3MoseXl+ozaRPf8/j/7ixzggg2nUipxKQRTDEXGZRytCisfvc44
# x2Dxq+vJQmlVbg4R/OJihMNprjAkmbWp/7uUxfrEMm5OHqsXjSAg9US4VaAiuFcE
# 9w9LLfAH1KpG36kKCILIj3NchgxwlPE+WHP90qflc22gWawLv+V87SE79lzbauzp
# OhyVE/9S1P2HHiLRiiURUKxcSEQm/tB0ehpNm1SMI6Xjhtco+oZaHJFKXTWPknVG
# ccTZwzzyF7kNolSlWT3CCl/nC0v5W07zZzERasVrTSsh3Q9lofIyXg==
# SIG # End signature block
