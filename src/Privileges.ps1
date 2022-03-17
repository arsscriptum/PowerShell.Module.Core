
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param(
        [Parameter(Mandatory=$false,Position=0)]
        [string]$Privilege

    )


class ChannelProperties
{
    #ChannelProperties
    [string]$Channel = 'PRIVILEGES'
    [ConsoleColor]$TitleColor = 'Blue'
    [ConsoleColor]$MessageColor = 'DarkGray'
    [ConsoleColor]$ErrorColor = 'DarkRed'
    [ConsoleColor]$SuccessColor = 'DarkGreen'
    [ConsoleColor]$ErrorDescriptionColor = 'DarkYellow'
}
$Script:ChannelProps = [ChannelProperties]::new()

function New-CustomAssembly{
    <#
        .SYNOPSIS
            Cmdlet to create a temporary assembly file (dll) with all the reference in it. Then include it in the script

        .EXAMPLE
            PS C:\>  
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="Assembly name") ]
        [string]$Source,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Assembly name") ]
        [switch]$Dll
    )    
       
    if($Dll){
        [string]$NewFile = (New-TemporaryFile).Fullname
        [string]$NewDllPath = (Get-Item $NewFile).DirectoryName
        [string]$NewDllName = (Get-Item $NewFile).Basename
        [string]$NewDllName += '.dll'
        $NewDll = Join-Path $NewDllPath $NewDllName
        Rename-Item $NewFile $NewDll
        Remove-Item $NewDll -Force
    }
    $CompilerOptions = '/unsafe'
    $OutputType = 'Library'

    #Try {
        if($Dll){
          $Result = Add-Type -TypeDefinition $Source -OutputAssembly $NewDll -OutputType $OutputType -PassThru 
          if(Test-Path $NewDll){
            return $NewDll
          }
        }
        else{
          return Add-Type $Source -PassThru 
        }

        return $null
   # }  
   # Catch {
   #     Write-Error "Failed to create $NewDll $_"
   # }    
}

Function Get-TokenManipulatorMembers
{
    [CmdletBinding()]
    Param ()
    $TypeObj = [TokenManipulator]
    $RawMembers = $TypeObj.GetMembers()

    [System.Collections.ArrayList]$OutputMembers = @()
    Foreach ( $RawMember in $RawMembers ) {
        
        $OutputProps = [ordered]@{
            'Name'= $RawMember.Name
            'MemberType'= $RawMember.MemberType
        }
        $OutputMember = New-Object -TypeName psobject -Property $OutputProps
        $OutputMembers += $OutputMember
    }
    $OutputMembers | Select-Object -Property * -Unique
}

function Invoke-AssemblyCreation{                               
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Add the type") ]
        [switch]$Dll,        
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Add the type") ]
        [switch]$Import        
    ) 

    $Source = Convert-FromBase64CompressedScriptBlock $Script:PrivilegesCsCode
    $Source = $Source.Replace('___CLASS_NAME___', $Script:CLASSNAME)

   # try{
      $SourceLen = $Source.Length
      if($Dll){
        $Result = New-CustomAssembly $Source -Dll
        if($Result -eq $Null) {  $Result = [TokenManipulator] ; return $Result}
        if($Import){
            $Obj = Add-Type -LiteralPath "$Result" -Passthru -ErrorAction Stop  
            Write-Host "Custom Type Added: $Result"    
            
            return $Obj
        }

        
      }else{
        $Result = New-CustomAssembly $Source
        if($Result -eq $Null) {  $Result = [TokenManipulator] ; return $Result}
        $Obj = $Result
      }
    #}
    #catch{
    #  Write-Host "Custom Type initialisation error : $_"
    #}
}

function Invoke-CorePrivLoad{                               
    [CmdletBinding(SupportsShouldProcess)]
    param(   
    ) 
    $Script:CLASSNAME = 'TokenManipulator'
    $Script:PrivilegesCsCode = "H4sIAAAAAAAACu1X3WsjNxB/P7j/QeTJgcXk0pdCuAcn3gb3nMTndQJtKUbendhby9JWH45Nm/+9o9V+aO04Jw761AZCovnNl2ZmRzNG5XxJkr3SsLn6+MF4x/7UcJ1voD/iGqQoEpDbPAWFbB8/kMIsWJ6SlFGlyHw+vxkPkmR+P7iL8YD4X/hLfhsyNtoUQureGc22tMh/uOxnjJ1FJN7RVCcFMGYtfiZaGohIAnpMlY6lFLIinv9uNeXWB04ZUZpqtAs7eyYLIRgZZH8YpWdiDXwi823OYAmqh15PtCQrLdaR48tyRRmLrDoJzwQFLPunsckzwuFF6ciaIQx4RCrpQsK2OUhA6Pzq8GJrdATYuxd79w6V9lvQN0ZKwJMUGGbVOzb178XwobDBK+2WgWzC52JC0zQqg+bIVlthI/tNF7/LmbEQa1M0uXyizEBPaWlvuRI2T9WB0w00+WQCKQXDbFZeJWgtRfN7YXTP/fmS86yfwJ8Gw5xTFpEJTdfo16cjp6xop0QsXhZ1Xfo2LjcCv5Ern1p6YfmvDnkHWsuS+NoxlQqudMmQxPPJdPQ0Gse38Xw4SgbX43iIzl3sLqqfqxDJ+P5I8PKU4OzhS3w///oYT3/x+X98n38w/PkxmbUmE0/20jlZt4dSssrWjQSqoSwvjIz7+UzOEvCAJulnJ9UMlMqXlnFD5b6jrVR2DHs6ySmlY5Gu72Aj5L5xzalrgRA1I57iXRR8NUJTX00HCLjkI1cCibmGbMQLoxtFh0CIV3c0XeUcBmlqy9XzqgsEuDWT2GkhuxEbNI2Ea7ySp2+WLgKUJJAameu9J1iTQlyga3h44SDVKi/8EHeAsJzTbIh8II9yXgMhtykfS+ydz8joa+kAIf44gRk+uQf+OMC+xSFqKosJ/m/tlj3dU/YWHHDNuoBtxpFdHCTwLTjEWffpT+gSfmrC5/UECxyE7xuaQG4ox+5+pKkGAlRd46Ng6tpyShwpQHYKSgvZKYSKFFQCK6Mz8cL95FekANtDWJhlt3RKUojlgcnyqjU0ndSSwgs35ttcCr6pg39Qvh4cks0V5Uu4Fzp/bjqyy6YHhPg2xd6tmyB2suIDQS05w7eg44wjBTUJng6WfmSa2FRAgJKY0wXDjCIXjkyCN0oOgbA3geO39SSYadtN9Sa0QEhf2BTYcQXHT6x7Mw8IbwS3TCxw4Ogk3ANCFNVPlITMDXnuQhIfubIRureiZULYQWEfNy5BddfEidb7xDvACUerWbfaWrKGqx5ui5pw3k6bWu7Lv+7kZCVoHIrdhNndY3RRUev5vUCX0MdT20XLiNM88rlT/1dc+Crc2ULoaEUodUcnZ8K//enSbQ/tyoD3Kvrl9Gyn75ZUXgKnyZZix2akvDXiHnr45t7ADe58bWSdI5Wl80MNb6+Sbod8pkw14hG5iPxgdQ6eWoM7jZ+tcvYnKdXpivTiXQpF+SXD7txPsl5J8YJET+b1RBnZNmYL7/9K+q5KGlZr1n+tlF7/AdNtqUb5EQAA"

    $type = Invoke-AssemblyCreation -Dll -Import   

    return $type    
}


# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnT0d+VGk7PzNLbcHE5reUBkT
# RyGgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUHB6a+UcCD7bF73dSggKv
# IeYXIjAwDQYJKoZIhvcNAQEBBQAEggEAAuRkVr5U4l8boDA4O3PdT8qBUPE8J0XJ
# m2xO20WJR/5Sad1KYOCWe1dwwMQdgAGnKHA6K070+hUKMc9uWNPPoRt6x5ec1OOW
# jtvvnfwNpIS0wvoVLLutOaV/C6us2MWUwEuxZCxVLgEWsrj+cE1gLIi9vw87XKdX
# 9i4ZX3A0i6RobNEec0GOyECdlMo861Nk3/MMO3p+Kg5Xk/LMhYiuoUXyrcVGFwEu
# g10X/Kcr08IxdX2Ia2TU3y45URHsDmNRZRojJyD2OxdwzTlSB7as+Ha07Pd7+aFY
# eHsYZkvK3XcOgGYXXmundyVfee6XPXuL5K8qyUXwLnRr770JCfF9gA==
# SIG # End signature block
