<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>
[CmdletBinding(SupportsShouldProcess)]
Param
(
    [Parameter(Mandatory = $false)]
    [switch]$Alias,
    [Parameter(Mandatory = $false)]
    [switch]$Quiet    
)



function Get-PSProfileDevelopmentRoot{

    if($ENV:PSProfileDevelopmentRoot -ne $Null){
        if(Test-Path $ENV:PSProfileDevelopmentRoot -PathType Container){
            $PsProfileDevRoot = $ENV:PSProfileDevelopmentRoot
            return $PsProfileDevRoot
        }
    }else{
        $TmpPath = (Get-Item $Profile).DirectoryName
        $TmpPath = Join-Path $TmpPath 'Profile'
        if(Test-Path $TmpPath -PathType Container){
            $PsProfileDevRoot = $TmpPath
            return $PsProfileDevRoot
        }

    }
    $mydocuments = [environment]::getfolderpath("mydocuments") 
    $PsProfileDevRoot = Join-Path $mydocuments 'PowerShell\Profile'
    return $PsProfileDevRoot
}

function Get-ModuleBuilderRoot{

    if($ENV:PSModuleBuilder -ne $Null){
        if(Test-Path $ENV:PSModuleBuilder -PathType Container){
            $PsProfileDevRoot = $ENV:PSModuleBuilder
            return $ModuleBuilder
        }
    }else{
        $TmpPath = (Get-Item $Profile).DirectoryName
        $TmpPath = Join-Path $TmpPath 'Projects\PowerShell.ModuleBuilder'
        if(Test-Path $TmpPath -PathType Container){
            $ModuleBuilder = $TmpPath
            return $ModuleBuilder
        }

    }
    $mydocuments = [environment]::getfolderpath("mydocuments") 
    $ModuleBuilder = Join-Path $mydocuments 'PowerShell\Projects\PowerShell.ModuleBuilder'
    return $ModuleBuilder
}


function Get-PSModuleDevelopmentRoot{

    if($ENV:PSModuleDevelopmentRoot -ne $Null){
        if(Test-Path $ENV:PSModuleDevelopmentRoot -PathType Container){
            $PSModuleDevelopmentRoot = $ENV:PSModuleDevelopmentRoot
            return $PSModuleDevelopmentRoot
        }
    }else{
        $TmpPath = (Get-Item $Profile).DirectoryName
        $TmpPath = Join-Path $TmpPath 'Module-Development'
        if(Test-Path $TmpPath -PathType Container){
            $PSModuleDevelopmentRoot = $TmpPath
            return $PSModuleDevelopmentRoot
        }

    }
    $mydocuments = [environment]::getfolderpath("mydocuments") 
    $PSModuleDevelopmentRoot = Join-Path $mydocuments 'PowerShell\Module-Development'
    return $PSModuleDevelopmentRoot
}


$DisplayName = 'Core'
$Script:Name = 'PowerShell.Module.Core'
$RegistryPath = "$ENV:OrganizationHKCU\$Name"
Write-Host "[$DisplayName] " -f Blue -NonewLin
Write-Host " $RegistryPath" -f White

$Script:ModuleDevelopmentPath =  Get-PSModuleDevelopmentRoot
$Script:ModuleSourcePath = Join-Path $ModuleDevelopmentPath $Script:Name

Write-Host "===============================================================================" -f DarkRed
Write-Host "Module Name `t" -NoNewLine -f DarkYellow ; Write-Host "$Script:Name" -f Gray 
Write-Host "Module Path `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:ModuleSourcePath" -f Gray 
Write-Host "Devel  Path `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:ModuleDevelopmentPath" -f Gray 
Write-Host "===============================================================================" -f DarkRed   

try{
    if($Quiet -eq $False){
        Write-Host "[$DisplayName] " -f Blue -NonewLine
        Write-Host "configuring registry values" -f White
    }

    Remove-Item $RegistryPath -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
    New-Item $RegistryPath -Force  -ErrorAction SilentlyContinue | Out-Null

    New-ItemProperty $RegistryPath -Name 'SourcePath' -Value  "$Script:ModuleSourcePath"  -ErrorAction SilentlyContinue
    [Environment]::SetEnvironmentVariable('PSModCore',"$Script:ModuleSourcePath",'User')

    $PSProfileDevelopmentRoot =  Get-PSProfileDevelopmentRoot
    [Environment]::SetEnvironmentVariable('PSModDev',"$Script:ModuleDevelopmentPath",'User')
    [Environment]::SetEnvironmentVariable('PSModuleDevelopmentPath',"$Script:ModuleDevelopmentPath",'User')
    [Environment]::SetEnvironmentVariable('PSProfileDevelopmentRoot',"$PSProfileDevelopmentRoot",'User')

}catch{
    Write-Host "[error] " -f DarkRed -NonewLine
    Write-Host "$_" -f DarkYellow    
}

# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVDkhlR1wu7Fr9yDZ2aW3mADn
# 8lOgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUmve/ynptfhv76JLFAWga
# FEIW13UwDQYJKoZIhvcNAQEBBQAEggEArQ56JNXGxBgF00tNKMNZOInVbEt2rgc2
# oFJYnL20iTgjOUowPVA9Eath5HuoJ3AFIueim1pp6JixQXnyUnFPdyxhqIPruWh7
# YLCdACwCHHYNLVkvvbgWuisuFq3fXBMYBxgoOLMZlJCB/cc8YopedPHNWCC5EpIC
# Mtmbmf+RrDCPgHMaGJ1XMN/70wf5+XA/yfGOqTtC8G6QFo8zIEV8smL/ACj+QNXA
# qvAjZ1pDdoEPqztkQR35V+A6J35R68ZymkoJmfrX4EUo5Cno1pMa09sOvBs6g7zv
# FKyLvUwsaLumRNId/bF0w+oyq65zCViFig0X4d+5XcepsGpS0b49Gg==
# SIG # End signature block
