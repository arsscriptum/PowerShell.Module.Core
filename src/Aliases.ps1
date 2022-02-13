<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

#===============================================================================
# Assemblies.ps1
#===============================================================================

New-Alias -Name ra -Value Register-Assemblies -Scope Global -ErrorAction Ignore -Force
#===============================================================================
# Date.ps1
#===============================================================================


New-Alias -Name datestr -Value Get-DateString -Scope Global -ErrorAction Ignore -Force
New-Alias -Name ctime -Value Get-Date -Scope Global -ErrorAction Ignore -Force
New-Alias -Name epoch -Value Get-UnixTime -Scope Global -ErrorAction Ignore -Force


#===============================================================================
# Directory.ps1
#===============================================================================
New-Alias -Name rmd -Value Remove-DirectoryTree -Scope Global -ErrorAction Ignore -Force
New-Alias -Name dirsize -Value Get-DirectorySize -Scope Global -ErrorAction Ignore -Force
New-Alias -Name getdir -Value Get-DirectoryItem -Scope Global -ErrorAction Ignore -Force
New-Alias -Name rsync -Value Sync-Directories -Scope Global -ErrorAction Ignore -Force
New-Alias -Name dirdiff -Value Compare-Directories -Scope Global -ErrorAction Ignore -Force
New-Alias -Name dircomp -Value Compare-Directories -Scope Global -ErrorAction Ignore -Force
New-Alias -Name foreachdir -Value Invoke-ForEachChilds -Scope Global -ErrorAction Ignore -Force


#===============================================================================
# Credential.ps1
#===============================================================================


New-Alias -Name Register-UserCredentials -Value Register-AppCredentials -Scope Global -ErrorAction Ignore -Force
New-Alias -Name Register-CustomCredentials -Value Register-AppCredentials -Scope Global -ErrorAction Ignore -Force
New-Alias -Name Register-Creds -Value Register-AppCredentials -Scope Global -ErrorAction Ignore -Force
New-Alias -Name Register-ApplicationCredentials -Value Register-AppCredentials -Scope Global -ErrorAction Ignore -Force
New-Alias -Name Get-AdminCreds -Value Get-ElevatedCredential -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# MessabeBox.ps1
#===============================================================================
New-Alias -Name msgbox -Value Show-MessageBox -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# Miscellaneous.ps1
#===============================================================================
New-Alias -Name cm -Value Get-CommandSource -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# Module.ps1
#===============================================================================
New-Alias -Name import -Value Import-CustomModule -Scope Global -ErrorAction Ignore -Description 'Import a Powershell Module very easily' -Force
New-Alias -Name install -Value Install-ModuleToDirectory -Scope Global -ErrorAction Ignore -Description 'Install a PowerShell Module in my personal directory' -Force

#===============================================================================
# Registry.ps1
#===============================================================================
New-Alias -Name reged -Value Start-RegistryEditor -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# Search.ps1
#===============================================================================
New-Alias -Name grep -Value Search-Pattern -Scope Global -ErrorAction Ignore -Force
New-Alias -Name find -Value Find-Item -Scope Global -ErrorAction Ignore -Force
New-Alias -Name search -Value Search-Item -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# Sudo.ps1
#===============================================================================
New-Alias -Name sudo -Value Invoke-ElevatedPrivilege -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# Sid.ps1
#===============================================================================
New-Alias -Name getsid -Value Get-USerSID -Scope Global -ErrorAction Ignore -Force
New-Alias -Name sid -Value Get-SIDUSerTable -Scope Global -ErrorAction Ignore -Force
#===============================================================================
# WebSearch.ps1
#===============================================================================
New-Alias -Name s -Value Invoke-WebSearch -Description "search the web, 's 'Star Wars' -e to search torent !" -Scope Global -ErrorAction Ignore  -Force
New-Alias -Name ws -Value Invoke-WebSearch -Description "search the web, 's 'Star Wars' -e to search torent !" -Scope Global -ErrorAction Ignore  -Force


New-Alias -Name parserepourl -value Split-RepositoryUrl -Force
New-Alias -Name parseurl -value Split-Url -Force
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU80MLatC7LlzdwGbqqL5+ubtY
# f0igggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUzUwFloNKgKcsDN/gaOp0
# SqVzTG8wDQYJKoZIhvcNAQEBBQAEggEAYGiVEBAhohSUzo3zl4engjWoGKE2Xhjb
# yEV5AZrvAcaPm846ca7XrOtSx3nUpygMOqtaoAcWDmn53hlyDFfGBOs1XFkRTGDN
# eKdCozK1WTrrSZULlZrapDOm3bZShaDmhUD2NQcqDmgv+svvV7phmhkANHCDnIWe
# sjze5wtoAidW40rrD1KPADrTnMsXrX5j0uu4TIjdI5xlK6Op+MushE8iTy7V1Mw7
# Ogp33A0GQq6YDcTw2CobAAEJrsERoyNi/4IRSYe7n3tca9e5arqcBYOBy41AKsyu
# ja+2HsccmBKEOCrsQj3ee1vfiizpxRQgAu1fNknYFMWK6qmClYWd0A==
# SIG # End signature block
