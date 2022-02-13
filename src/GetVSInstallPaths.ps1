<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   Get-VSInstallPaths          
  ║   
  ║   Get Visual Studio Install Paths, using vswhere, or if not present, the registry
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>


    function Get-VSInstallPaths{  
        [CmdletBinding(SupportsShouldProcess)]
        Param
        (
            [Parameter(Mandatory=$false)]
            [switch]$UseCim,
            [Parameter(Mandatory=$false)]
            [switch]$PreRelease
        )     
 
        try
        {
          $DetectedInstances = [System.Collections.ArrayList]::new()
          $vswhere = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe'
          if((Test-Path $vswhere) -And ($UseCim -eq $False)){
            Write-Verbose "use vswhere"
            $JsonData = ''
            $PreReleaseArg = ''
            if($PreRelease){
                $PreReleaseArg = "-prerelease"
            }
            $JsonData = &"$vswhere" "-legacy" "$PreReleaseArg" "-format" "json"
            $VSInstallData = @($JsonData | convertFrom-Json)
            $VsCount=$VSInstallData.Count
            Write-Verbose  "Found $VsCount VS entries"
            foreach($vse in $VSInstallData){
                $obj = [PSCustomObject]@{
                    Name = $vse.displayName
                    Description = $vse.description
                    Version = $vse.installationVersion
                    InstallDate = $vse.installDate
                    InstallationPath = $vse.installationPath
                }
                Write-Verbose "installation found: $obj"
                $null=$DetectedInstances.Add($obj)
            }
          }else{
            # use the CimInstance
            Write-Verbose "use CimInstance"
            $VSInstallData = (Get-CimInstance MSFT_VSInstance)
            $VsCount=$VSInstallData.Count
            Write-Verbose  "Found $VsCount VS entries"
            foreach($vse in $VSInstallData){
                $obj = [PSCustomObject]@{
                    Name = $vse.Name
                    Description = $vse.Description
                    Version = $vse.Version
                    InstallDate = $vse.InstallDate
                    InstallationPath = $vse.InstallLocation
                }
                Write-Verbose "installation found: $obj"
                $null=$DetectedInstances.Add($obj)
          }
         }
         return $DetectedInstances
        }
        catch
        {
            Write-Host -n -f DarkRed "[error] "
            Write-Host -f DarkYellow "$_"
        }
    }
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU07ip4Ede22NK9ESnjJ3UH1Ax
# Fs+gggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUiVo2ypdVMpQjzacmESs4
# qGmzdIswDQYJKoZIhvcNAQEBBQAEggEAHxLbSBQp75FPXQQpoXdRc3sK2cCwgiPM
# VLt8zwwdyR8te419dCgXMhCyaO04xug8l632OsNHJyYWorvtdX+FqGkZjyKwr1Am
# QOmS8B9AmKBT41ilupjDGTSQt+WEzHMdMLmZW4OfcIr7oxdfPpfNccQGgbxaq/PN
# 17RwnRZabwEczZ2bGuQNQB0/15i9a98PywPk4T0cCctP71u81Apbj3lQC2yFIIRi
# lrbQ/Re7N0oXvBx3DnzoU7l2fcIsWgGHLGCIX8noy14kcOhmui+pj6HLEr0OF0/v
# M2gubs0hT//tobYxJrCOziK0ZsFraziUP1kxnYxNFenbRR3ArhE0pA==
# SIG # End signature block
