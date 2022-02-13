<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>
#Load required libraries 

$Script:WindowsAssemblyReferences = @()
$Script:WindowsAssemblyReferences += 'PresentationFramework'
$Script:WindowsAssemblyReferences += 'PresentationCore'
$Script:WindowsAssemblyReferences += 'WindowsBase'
$Script:WindowsAssemblyReferences += 'System.Windows.Forms'
$Script:WindowsAssemblyReferences += 'System.Drawing'
$Script:WindowsAssemblyReferences += 'System' 
$Script:WindowsAssemblyReferences += 'System.Xml' 
if($PsVersionTable.PsVersion.Major -eq 5){
    $Script:WindowsAssemblyReferences += 'System.Speech'
}
function Show-AssemblyReferences{
    <#
        .SYNOPSIS
            Cmdlet to list all current references in the array.
        

        .EXAMPLE
            PS C:\> Assembly-List-References
    #>
    Write-Verbose "List all current references in WindowsAssemblyReferences" -f Cyan
    $Script:WindowsAssemblyReferences | ForEach-Object {
        Write-Verbose "Assembly: " -f Cyan -NoNewLine
        Write-Verbose " [$PSItem]" -f Magenta
    }
}

function Add-AssemblyReference{
    <#
        .SYNOPSIS
            Cmdlet to add a reference in the reference array

        .PARAMETER Assembly
            A string representing the assembly to add.

        .EXAMPLE
            PS C:\> Assembly-Add-Reference 'System.Drawing'
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="Assembly name") ]
        [ValidateNotNullOrEmpty()]
        [Alias('n')]
        [string]$Assembly,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="call AddType") ]
        [Alias('i')]
        [switch]$Import
    )
    $Script:WindowsAssemblyReferences += $Assembly
    Write-ChannelMessage "$Assembly"
    if($Import){
        Add-Type -AssemblyName $Assembly
        Write-ChannelMessage "Importing AssemblyNam $Assembly"
    }

}

function New-AssemblyReferences{
    <#
        .SYNOPSIS
            Cmdlet to create a temporary assembly file (dll) with all the reference in it. Then include it in the script

        .EXAMPLE
            PS C:\>  
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Assembly name") ]
        [string]$Source,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="call AddType") ]
        [Alias('i')]
        [switch]$Import
    )    
    
    If( $PSBoundParameters.ContainsKey('Source') -eq $False ){
        $Source = @"
        using System;
        namespace MyControl
        {
        //  C# Source
        }
"@        
    }
    $AssemblyReferences = @()
    $AssemblyReferences += 'System' 
    $AssemblyReferences += 'System.Xml'     
    $NewFile = (New-TemporaryFile).Fullname
    $NewDllPath = (Get-Item $NewFile).DirectoryName
    $NewDllName = (Get-Item $NewFile).Basename + '.dll'
    $NewDll = Join-Path $NewDllPath $NewDllName
    Rename-Item $NewFile $NewDll
    $CompilerOptions = '/unsafe'
    $OutputType = 'Library'
    Write-ChannelMessage "NewDll $NewDll"
    Write-ChannelMessage "CompilerOptions $CompilerOptions"
    Write-ChannelMessage "OutputType $OutputType"
    Write-ChannelMessage "Source $Source"
    Write-ChannelMessage "Dependencies $AssemblyReferences"
    Try {
        Write-Verbose "Add-Type -TypeDefinition $Source -OutputAssembly $NewDll -CompilerOptions $CompilerOptions -ReferencedAssemblies $AssemblyReferences -OutputType $OutputType -PassThru"
        $Result = Add-Type -TypeDefinition $Source -OutputAssembly $NewDll -CompilerOptions $CompilerOptions -ReferencedAssemblies $AssemblyReferences -OutputType $OutputType -PassThru
        Add-Type -LiteralPath $NewDll -ErrorAction Stop
        Write-ChannelResult "$$Result"
        return $NewDll
    }  
    Catch {
        Write-Warning -Message "Failed to import $_"
    }    
}

function Register-Assemblies{

    [CmdletBinding(SupportsShouldProcess)]
    param()
    $ErrorOccured = $False
    if($ENV:FLAG_REGISTER_ASSEMBLIES -eq $null){
        Foreach ($Ref in $Script:WindowsAssemblyReferences) {
        Try {
            Write-Verbose "Adding: $Ref"
            Add-Type -AssemblyName $Ref
        }  
        Catch {
            Write-Warning -Message "Failed to import $Ref"
            $ErrorOccured = $True
        }
        if($ErrorOccured -eq $False){
            $ENV:FLAG_REGISTER_ASSEMBLIES = 'OK'
            [environment]::SetEnvironmentVariable('FLAG_REGISTER_ASSEMBLIES',"OK",'Process')    
        }
    }
    }else{
        Write-Verbose "Already registered"
    }
}

# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtTJMLtU6DwtseDtenpjg7WMR
# 4SSgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUDYeREpanTKnJ5XNwCDNd
# R40/rdYwDQYJKoZIhvcNAQEBBQAEggEAj0NsI1TvOFsUViexwDLAJz4v4L8nT7qv
# 5qboIPN57qJAyRc5ckfBxDWXRMgRPdho69NEF9GP4MEXukaHx1cu2Aog+OQ6r5A4
# ZeK0P+gdDWmlJCNvFIFU9/vgCAlwVzv97ubrmEsOnxFc10VJj0O3ZsFG79x2em4z
# +ooOv9kjn3gPTdV4vJh/rrYd1QY1QtXcmjxVo+0KXojlBoTc4bLBbZ9wH/BAXF/t
# UoDQqpmUkJQ+jqWMdl0IFsfs9KjAhgTw2NDJl0xbfUfXv+Zp6EiZAZMnN8Og9lnq
# jNW0jx5VUkIqZEZjiHfuyRcU69+uu6tZc0F2Mt8+OIp0FlrEK9z4OQ==
# SIG # End signature block
