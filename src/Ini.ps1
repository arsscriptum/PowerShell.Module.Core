<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


Function Get-IniFile ($file)       # Based on "https://stackoverflow.com/a/422529"
 {
    $ini = [ordered]@{}

    # Create a default section if none exist in the file. Like a java prop file.
    $section = "NO_SECTION"
    $ini[$section] = [ordered]@{}

    switch -regex -file $file 
    {    
        "^\[(.+)\]$" 
        {
            $section = $matches[1].Trim()
            $ini[$section] = [ordered]@{}
        }

        "^\s*(.+?)\s*=\s*(.*)" 
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value.Trim()
        }

        default
        {
            $ini[$section]["<$("{0:d4}" -f $CommentCount++)>"] = $_
        }
    }

    $ini
}

Function Set-IniFile ($iniObject, $Path, $PrintNoSection=$false, $PreserveNonData=$true)
{                                  # Based on "http://www.out-web.net/?p=109"
    $Content = @()
    ForEach ($Category in $iniObject.Keys)
    {
        if ( ($Category -notlike 'NO_SECTION') -or $PrintNoSection )
        {
            # Put a newline before category as seperator, only if there is none 
            $seperator = if ($Content[$Content.Count - 1] -eq "") {} else { "`n" }

            $Content += $seperator + "[$Category]";
        }

        ForEach ($Key in $iniObject.$Category.Keys)
        {           
            if ( $Key.StartsWith('<') )
            {
                if ($PreserveNonData)
                    {
                        $Content += $iniObject.$Category.$Key
                    }
            }
            else
            {
                $Content += "$Key = " + $iniObject.$Category.$Key
            }
        }
    }

    $Content | Set-Content $Path -Force
}


### EXAMPLE
##
## $iniObj = Get-IniFile 'c:\myfile.ini'
##
## $iniObj.existingCategory1.exisitingKey = 'value0'
## $iniObj['newCategory'] = @{
##   'newKey1' = 'value1';
##   'newKey2' = 'value2'
##   }
## $iniObj.existingCategory1.insert(0, 'keyAtFirstPlace', 'value3')
## $iniObj.remove('existingCategory2')
##
## Set-IniFile $iniObj 'c:\myNewfile.ini' -PreserveNonData $false
##


<#

[void][system.reflection.assembly]::loadfrom("nini.dll") (refer add-type now in ps2 )
$scriptDir = Split-Path -parent $MyInvocation.MyCommand.Definition
Add-Type -path $scriptDir\nini.dll

$source = New-Object Nini.Config.IniConfigSource("e:\scratch\MyApp.ini")

$fileName = $source.Configs["Logging"].Get("File Name")
$columns = $source.Configs["Logging"].GetInt("MessageColumns")
$fileSize = $source.Configs["Logging"].GetLong("MaxFileSize")

#>
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9n7aYtNMh3pi/NVXkxkIAk3u
# etigggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQULgqTRiZvfSZRbeecLdAc
# 64Wy4mkwDQYJKoZIhvcNAQEBBQAEggEAyhQKLA+qck7yPJUM0fCmvukDpwoHOrem
# FvrQPFWKKuLxlZrBmU+eKztQiuzdzt2NC/PPP3LaDreucSMRp+NXegjLhVhBc5EK
# R2Uj69HU3F3k0lRQ3imQvG1btuh7dbUPOvvq16ZxhHOrWp+/sNdzg0z2MGC8RgKC
# IDEeLrFXRY+3Wyyg16YUCE0fu7bopG8PgBQhJZ8AOvxCc67KPwE4seku1xY2446K
# NJfd/zw6L2Fq/V/tpM8N9Rhl/EjII+Mm4477/WKRd5ZuCMXA0r9y33vuEF6peF5q
# ISMUmw7hQvRXWIW2KHxx+mojYnt6SLeDSmeEkYRodfM0op91R1u4XA==
# SIG # End signature block
