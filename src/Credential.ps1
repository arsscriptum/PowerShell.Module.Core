<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>




function Show-RegisteredCredentials {
<#
    .SYNOPSIS
            Cmdlet to register new credentials in the DB

    .PARAMETER Id
            Application Id

#>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false)]
        [string]$Filter,
        [Alias("global","allusers")]
        [Parameter(Mandatory=$false)]
        [switch]$GlobalScope
    )  
    $RegKeyCredsManagerRoot = "$ENV:OrganizationHKCU\credentials-manager"
    if($GlobalScope){
         If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
            Write-Host "GlobalScope Requires Admin privilege"
            return $false
        }
        $RegKeyCredsManagerRoot = "$ENV:OrganizationHKLM\credentials-manager"
        $RegKeyRoot = "$ENV:OrganizationHKLM\$Id\credentials"
    }

    $Entries = [System.Collections.ArrayList]::new()
    $ItemProperties=Get-ItemProperty $RegKeyCredsManagerRoot
    $List = (Get-Item $RegKeyCredsManagerRoot).Property
    foreach ($id in $List){
        $UnixTime=$ItemProperties."$id"
        $epoch = [DateTime]::SpecifyKind('1970-01-01', 'Utc')
        $RegisteredDate = $epoch.AddSeconds($UnixTime)
        $c = Get-AppCredentials -Id $id -GlobalScope:$GlobalScope
        $Entry = [PSCustomObject]@{
                Id              = $id
                UnixTime        = $UnixTime
                RegisteredDate  = $RegisteredDate
                Credentials     = $c
        }
        $Entries.Add($Entry)
    }
    return $Entries
}


function Register-AppCredentials {
<#
    .SYNOPSIS
            Cmdlet to register new credentials in the DB

    .PARAMETER Id
            Application Id

#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Id,
        [Alias("global","allusers")]
        [Parameter(Mandatory=$false)]
        [switch]$GlobalScope
    )  
    $RegKeyCredsManagerRoot = "$ENV:OrganizationHKCU\credentials-manager"
    $RegKeyRoot = "$ENV:OrganizationHKCU\$Id\credentials"
    if($GlobalScope){
         If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
            Write-Host "GlobalScope Requires Admin privilege"
            return $false
        }
        $RegKeyCredsManagerRoot = "$ENV:OrganizationHKLM\credentials-manager"
        $RegKeyRoot = "$ENV:OrganizationHKLM\$Id\credentials"
    }

    $Credentials = Get-Credential
    $Username = $Credentials.UserName
    $Passwd=ConvertFrom-SecureString $Credentials.Password
          
    $Now = Get-Date
    $epoch = [DateTime]::SpecifyKind('1970-01-01', 'Utc')
    $epoch = [Int64]($Now.ToUniversalTime() - $epoch).TotalSeconds
    New-RegistryValue -Path $RegKeyCredsManagerRoot -Name "$Id" -Type "DWORD" -Value $epoch
    $r1=New-RegistryValue -Path $RegKeyRoot -Name "username" -Value $Username -Type "String"
    $r2=New-RegistryValue -Path $RegKeyRoot -Name "password" -Value $Passwd   -Type "String"

    return ($r1 -And $r2)
}

function Get-AppCredentials {
<#
    .SYNOPSIS
            Cmdlet to register new credentials in the DB

    .PARAMETER Id
            Application Id

#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Id,
        [Alias("global","allusers")]
        [Parameter(Mandatory=$false)]
        [switch]$GlobalScope
    )  

    $Path="$ENV:OrganizationHKCU\$Id\credentials"
    if($GlobalScope){
         If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
            Write-Host "GlobalScope Requires Admin privilege"
            return $false
        }
        $Path = "$ENV:OrganizationHKLM\$Id\credentials"
    }
    if(-not(Test-Path $Path)){
        return $null
    }
   
    $Username = Get-RegistryValue $Path "username"
    $Passwd = Get-RegistryValue $Path "password"
    $Password = ConvertTo-SecureString $Passwd
    $Credentials = New-Object System.Management.Automation.PSCredential $Username,$Password

    return $Credentials
}

function Get-ElevatedCredential {
<#
    .SYNOPSIS
            Cmdlet to get recorder elevated privilege
    .DESCRIPTION
            Cmdlet to get recorder elevated privilege, record it using the -Reset parameter

    .PARAMETER Reset
             Reset the elevated privilege user/password

#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false)]
        [Alias("r")]
        [switch]$Reset,
        [Alias("global","allusers")]
        [Parameter(Mandatory=$false)]
        [switch]$GlobalScope
    )  
    $AppName="DevApp"
    if($Reset.IsPresent){
        Write-Output "Setting credentials"
        $Set=Register-AppCredentials $AppName -GlobalScope:$GlobalScope
        if($Set -eq $false){
            Write-Error "Problem recording credentials"
            return $null
        }
    }
    
    $Creds=Get-AppCredentials $AppName -GlobalScope:$GlobalScope
    if($Creds -ne $null){
        return $Creds
    }
    Write-Error "No elevated credentials were registered. (use Reset param)"
    return $null
}


# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQURp2oYuAqWSrJIkBnNorNdVtC
# 1KGgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUdpA9Hyxd9Ka9mkNlbg4B
# 0ma2GSQwDQYJKoZIhvcNAQEBBQAEggEAL71WUOqkjVt+G9o2fwQwba7EEq61sV8d
# Tbr3xAAXFNyQon+VlZvJBP6Eh1QD6YpoAZirbeDEquY2g2+NLRQ1PL7BFO1Ea+ic
# 1iPd7ujtRsHCo9gyF2kwUHFrJSoOFOBJLcxqNkLAHO6BAR8k2nouTRzVM/Q2Jv+0
# j4pwh+fKXebhBDlRovCehddk8QGtkWalWWC8xYy4HGIQzCzldpx8HG+P0WD7GnkG
# r+iUhXg56Jaz2eFKMaL1jVHMedaojaJYV7/7rqDaWTSN14i3FL83mVPICZ2/N9ln
# GtvKAuoKnm0HTHh5qXFJFqGmfGd5jJZl70sfz0JLHwKeR0fF4fssBw==
# SIG # End signature block
