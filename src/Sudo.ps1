<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   Invoke-ElevatedPrivilege       
  ║   
  ║   Invoke a command with Elevated Privilege Note that this uses PowerShell Core (pwsh.exe)
  ║   to use legacy powershell, change pwsh.exe to powershell.exe
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>


function Invoke-ElevatedPrivilege{

    try {

        $NumArgs = $args.Length
        if($NumArgs -eq 0){ 
            Write-Warning "No Command Specified..."
            return 
        }

        $SudoedCommand = ''
        ForEach( $word in $args)
        {
            $SudoedCommand += $word
            $SudoedCommand += ' '
        }
    $SudoedCommand += ' '

    $bytes = [System.Text.Encoding]::Unicode.GetBytes($SudoedCommand)
    $encodedCommand = [Convert]::ToBase64String($bytes)


    $PwshExe = (Get-Command "pwsh.exe").Source
    $ArgumentList = " -noprofile -noninteractive -encodedCommand $encodedCommand"

    Start-Process -FilePath $PwshExe -ArgumentList $ArgumentList -Verb RunAs

    }catch{
        [System.Management.Automation.ErrorRecord]$Record = $_
        $formatstring = "{0}`n{1}"
        $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
        $ExceptMsg=($formatstring -f $fields)
        $Stack=$Record.ScriptStackTrace
        Write-Host "[Invoke-ElevatedPrivilege] -> " -NoNewLine -ForegroundColor Red; 
        Write-Host "$ExceptMsg" -ForegroundColor Yellow
    }
}

# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbun1TcI2tPFh+4httHN8M5UF
# quKgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUBpdlMG4JffqlRlkBuSss
# g4Z9l/4wDQYJKoZIhvcNAQEBBQAEggEARKNi82dTdcA1HQexHczds/2CJVNH+XkO
# J48kNoV0v0b5w7IMxdV44iHPCXaZ4MDGeTuAFhLczVnbMsbDh38ZUcxZ3ylGNpqm
# 8guCqVb3RZyeG2mgt6XCKbKIpDy1G95WpeLjJA0bAgS+Z3KcblefDgtvyC5FJ8Qi
# JURWIzzOPIKbZvA3ja7WnIWvyZAJKcyycXxKIde/A27EGA+cik6JGPvTIl2GAh7Z
# Ui8+Hd1F1ZeNbtLITQ3PYkZaFzDYrfzJFQm0R2NRyay9Fg0ld0pubZLTlA7zZstv
# k/iZ9f9ock8RkmW4Jwymex2n7RTH46jpkSEILe77wXV/iOVkjAoOlg==
# SIG # End signature block
