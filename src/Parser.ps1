

function Remove-CommentsFromScriptBlock {

    [CmdletBinding()] 
    param(
        [String]$ScriptBlock
    )
    $IsOneLineComment = $False
    $IsComment = $False
    $Output = ""
    $NoCommentException = $False

    $Arr=$ScriptBlock.Split("`n")
    ForEach ($Line in $Arr) 
    {
        if ($Line -match "###NCX") { ###NCX
            $NoCommentException = $True
        }

        if ($Line -like "*<#*") {   ###NCX
            $IsComment = $True
        }

        if ($Line -like "#*") {     ###NCX
            $IsOneLineComment = $True
        }

        if($NoCommentException){
            $Output += "$Line`n"
        }
        elseif (-not $IsComment -And -not $IsOneLineComment) {
            $Output += "$Line`n"
        }

        $IsOneLineComment = $False

        if ($Line -like "*#>*") {   ###NCX
            $IsComment = $False
        }
    }

    return $Output
}

# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUKwQaln13X7caPDp8283+SLVz
# Z3SgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUs3VzmnQgI6iDQHf1nP1O
# zLOhpKswDQYJKoZIhvcNAQEBBQAEggEA6D35AHwr3PfH356c/uHWJfARwbgl6Yay
# /Yn8f9foB/lF36KgKqd1lzLeA3toMAMyb7atHntMQUDLTGOPXJPkk22lgKy4x+73
# Wa8e2b1kQrwygAQwh3ZD7IBPLaHluE5Xza8jRbaRCgaGtyuHyCy2Hy8Nzy1fegpl
# 6XWcF/mUjzoa9lp0P2yMBYoe7HDqZaQxxJmiH6+QsqybBnJW/WzuTgZfkL+lnOPE
# eL7OoVeZkLwtqPKF8Fz5s+06Rg3FLMu39f/iq9Pm4dDzCHxKwWNipo+2SwI3yqxS
# DyRVwttVRFSqh/ly2OOYoVPmTUckEn9//8siskiLrWHf2krW7SnReA==
# SIG # End signature block
