<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell Copy-DirectoryTree  
  ║   Copy-DirectoryTree.ps1
  ║
  ║    Example: 
  ║    Copy-DirectoryTree -Source 'c:\Temp' -Destination 'c:\Tmp\New' -Verbose -Force -Exclude 'xxdevdriver'
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>


function Copy-DirectoryTree { 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "Folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Container) ){
                throw "The Path argument must be a Directory. Files paths are not allowed."
            }
            return $true 
        })]
        [Parameter(Mandatory=$true)]
        [String]$Source,
        [Parameter(Mandatory=$true)]
        [String]$Destination,
        [Parameter(Mandatory=$false)]
        [String]$Exclude,
        [Parameter(Mandatory=$false)]
        [switch]$Force
        
    )
    $Tree = [System.Collections.ArrayList]::new()   
    $Source=(Resolve-Path $Source).Path
    if ($Source.Chars($Source.Length - 1) -ne '\'){
        $Source = ($Source + '\')
    }

    $obj = [PSCustomObject]@{
        Source = $Source
        Copy = ''
    }
    $null=$Tree.Add($obj)

    $DestExists=Test-Path $Destination -PathType Container -ErrorAction Ignore
    if($DestExists){
        Write-Warning "$Destination exists"
        If( $Force ){
            Write-Warning "Force: deleting $Destination"
            $Null=Remove-Item -Path $Destination -Force -ErrorAction Ignore -Recurse
        }else{
            Write-Warning "Use -Force to overwrite"
            return
        }
    }

    $Null=New-Item -Path "$Destination" -Force -ErrorAction Ignore -ItemType Container

    Push-Location $Destination
    try{
        If( $PSBoundParameters.ContainsKey('Exclude') -eq $True ){
            $DirList = Get-ChildItem $Source -Recurse -ErrorAction Ignore -Directory | where Fullname -notmatch "$Exclude"
            if($DirList -eq $Null){
                write-verbose "no sub directories in $Source (excluding $Exclude)"
                return
            }

            $DirList = $DirList.Fullname | sort -Descending -unique
                
        }else{
            $DirList = (Get-ChildItem $Source -Recurse -Force -ErrorAction Ignore -Directory)
            if($DirList -eq $Null){
                write-verbose "no sub directories in $Source"
                return
            }
            $DirList = $DirList.Fullname | sort -Descending -unique
        }
        $NumFolders = $DirList.Length
        $len = $Destination.Length-2
        write-verbose "$NumFolders sub directories in $Source"
        ForEach($Dir in $DirList){
            $rel = $Dir.SubString($len, $Dir.Length-$len)
            $NewFolder = Join-Path $Destination $rel
            write-verbose "create $NewFolder"
            $Null=New-Item -Path "$NewFolder" -Force -ErrorAction Ignore -ItemType Container
            $obj = [PSCustomObject]@{
                Source = $Dir
                Copy = $NewFolder
            }
            $null=$Tree.Add($obj)
        }
        return $Tree
    }catch {
        Show-ExceptionDetails $_ -ShowStack
        Write-Host "[Copy-DirectoryTree error] " -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
    finally{
        popd
        
    }
} 



# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUULOzKDVrhQIk64PJlM3Aq3Rc
# f8CgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUgZWtsMb9CYQg0fFKblVs
# fzlkcocwDQYJKoZIhvcNAQEBBQAEggEAaClr+f4VrvzzG7Ax65SXIkCSM97HYy6m
# MGb2vquVIKyTN5dGETsFJ8nxz2ntZVFkj3TgQZHNksK/JExDBhVKCo89iQgLRSaV
# qhlVAHiXNCHHWnHb7qZ46ZRaLFL1DsIc0Ou9rEXLep/aa2TCW6Sqs4u0rzKtFGLj
# AiI/3DbrkRkpZmZsk3DyNPIOv5iBXsIa24BsZCye1JI8imx9QSlENmSZtDlK0Cw3
# rUPLBlTO+z8jAgbxYv6+shckOwC2cMQtzmOoAYsxWbEw5rFM0RrzYxvdXdf3MQP5
# c14aV4MplwvuN8nMK3UvD5wdfxNxrLo5U7RZz7xAyDJPEp0yyksFlA==
# SIG # End signature block
