<#̷#̷\
#̷\ 
#̷\   ⼕ㄚ乃㠪尺⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\    
#̷\   𝘗𝘰𝘸𝘦𝘳𝘴𝘩𝘦𝘭𝘭 𝘚𝘤𝘳𝘪𝘱𝘵 (𝘤) 𝘣𝘺 <𝘮𝘰𝘤.𝘥𝘶𝘰𝘭𝘤𝘪@𝘳𝘰𝘵𝘴𝘢𝘤𝘳𝘦𝘣𝘺𝘤>
#̷\ 
#̷##>




Function New-ScheduledTaskFolder{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$TaskPath
    )
    $BackupEA = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    Log-String "New-ScheduledTaskFolder called with path $TaskPath"


    $scheduleObject = New-Object -ComObject schedule.service
    $scheduleObject.connect()
    $rootFolder = $scheduleObject.GetFolder("\")
    Try 
    {
        $null = $scheduleObject.GetFolder($TaskPath)
    }
    Catch { 
        $null = $rootFolder.CreateFolder($TaskPath) 
        $ErrorActionPreference = $BackupEA
    }
    Finally { 
        $ErrorActionPreference = $BackupEA
    } 
}



function Install-SimpleTask {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Id,
        [Parameter(Mandatory=$true)]
        [datetime]$When,
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
                throw "The Path argument must be a File. Directory paths are not allowed."
            }
            return $true 
        })]
        [Parameter(Mandatory=$true)]
        [string]$ScriptPath,
        [Parameter(Mandatory=$false)]
        [string]$User,
        [Parameter(Mandatory=$false)]
        [switch]$EncodeB64
    )

    if ($PSBoundParameters.ContainsKey('User') -eq $False) {
        $User = whoami
    }

    $PWSHEXE = (Get-Command pwsh.exe).Source
    $me = whoami
    $trigger = New-ScheduledTaskTrigger -Once -At $When
    
    $settings = New-ScheduledTaskSettingsSet -Hidden -Priority 3
    $principal = New-ScheduledTaskPrincipal -UserID "$User"
    #$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    if($EncodeB64){
        $command = Get-Content -Path $ScriptPath -Raw
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        $action = New-ScheduledTaskAction -Execute "$PWSHEXE" -Argument "-ep Bypass -nop -W Hidden -NonI -EncodedCommand `"$encodedCommand`""
        $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
        $ResultingTask = Register-ScheduledTask $Id -InputObject $task


        $T_State = ($ResultingTask).State
        $T_Name = ($ResultingTask).TaskName

        Write-Host "[SCHEDULED TASK] " -f DarkYellow -n
        Write-Host "Name ==> $T_Name. State ==> $T_State" -DarkGreen
    }else{
        $action = New-ScheduledTaskAction -Execute "$PWSHEXE" -Argument "-ep Bypass -nop -W Hidden -NonI -File `"$ScriptPath`""
        $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
        $ResultingTask=Register-ScheduledTask $Id -InputObject $task


        $T_State = ($ResultingTask).State
        $T_Name = ($ResultingTask).TaskName

        Write-Host "[SCHEDULED TASK] " -f DarkYellow -n
        Write-Host "Name ==> $T_Name. State ==> $T_State" -DarkGreen
    }
}
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqlhjD8CrbA2IpC9KwvCDaQhY
# SiCgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUWFqfcmKCTm6gxN8rHlVc
# pVOa4yAwDQYJKoZIhvcNAQEBBQAEggEAUIN5677aUSetUtfVWFLoj3ILzorgdEsa
# pz6f6blF/ZRtoZKq8tskGnz7ixLmqgKwm5lP82RPQce4Zgk35xY7ShCJ0S9Yizye
# gdLYaCUU5qzazvQ5n4E9xkNsM7PCU0D0DDm5YtAVOR7qp68IvagQ7c2CVkVxHNel
# u1uNj906tsu5BFy8rno0vid2MAX9iUOJL+FCSdb4ZfiG70FfFou4rPssYOubQhxi
# BiaYUVBq8ZSnCkPBeivZVlih+Iq1jmZlrbYhMynQKiTtjh3K6lpiZ2h745wTenLX
# iglg7NtoTj9aSGU34qBV9Ajfgv7ZOLd9Nk3rmyNJIo27Gk6xZwcj/g==
# SIG # End signature block
