<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>




function AutoUpdateProgress {   # NOEXPORT
    $Len = $Global:ServiceName.Length
    $Diff = 50 - $Len
    For($i = 0 ; $i -lt $Diff ; $i++){ $Global:ServiceName += '.'}
    $Global:ProgressMessage = "$Global:ServiceName... ( $Global:StepNumber on $Global:TotalSteps) (W) by $Global:User $Global:FoundCount"
    Write-Progress -Activity $Global:ProgressTitle -Status $Global:ProgressMessage -PercentComplete (($Global:StepNumber / $Global:TotalSteps) * 100)

}

function CheckAdmin {
    #This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
        return $False
    }
    return $True
}



function Disable-Service
{
<#
	.SYNOPSIS
		Get-ScriptDirectory returns the proper location of the script.

	.OUTPUTS
		System.String
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Name
        )

    Try{

        Write-ChannelMessage "Disable-Service $Name"
        $ServicePtr = Get-Service -Name $Name -ErrorAction Ignore
        if($ServicePtr -eq $Null){
            throw "INVALID SERVICE NAME"
        }
        Write-ChannelMessage "Stopping service $Name"
        Stop-Service -Name $Name -ErrorAction Ignore
        Write-ChannelResult "Stopped."
        Write-ChannelMessage "Setting StartupType to Disabled"
        Set-Service -Name $Name -StartupType Disabled -ErrorAction Ignore
        Write-ChannelResult "StartupType set to Disabled"

        $ServicePtr = Get-Service -Name $Name -ErrorAction Ignore
        if($ServicePtr -eq $Null){
            throw "INVALID SERVICE NAME"
        }

        $ServicePtr | Select *
    }catch [Exception]{
        Write-Host '[ERROR] ' -f DarkRed -NoNewLine
        Write-Host " Disable-Service $_" -f DarkYellow
    }

}

function List-WriteableServices
{
<#
    .SYNOPSIS
        Get-ScriptDirectory returns the proper location of the script.

    .OUTPUTS
        System.String
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [String]$User,
        [Parameter(Mandatory=$false)]
        [String]$ServiceName,        
        [Parameter(Mandatory=$false)]
        [switch]$NoProgress        
    )

    Try{

        Write-Verbose "List-WriteableServices $Name"
        if ($PSBoundParameters.ContainsKey('ServiceName')) {
            [array]$ServiceList = (Get-Service | where Name -match "$ServiceName").Name
        }else{
            [array]$ServiceList = (Get-Service).Name
        }
        
        if($ServiceList -eq $Null){
            throw "INVALID SERVICE NAME"
        }
        $ServiceListLen = $ServiceList.Length
        $AccessChkExe = (Get-Command 'accesschk.exe').Source
        $WriteableServices = [System.Collections.ArrayList]::new()        
        $Global:ProgressTitle = 'ANALYSING SERVICES'
        $Global:StepNumber = 0
        $Global:TotalSteps = $ServiceListLen
        $Global:ErrorList = [System.Collections.ArrayList]::new()
        $Global:ErrorCount = 0
        $Global:User = $User
        $Global:FoundCount = 0
        if( $NoProgress -eq $False ) { AutoUpdateProgress }
        For($i = 0 ; $i -lt $ServiceListLen ; $i++){
            $Global:ServiceName = $ServiceList[$i]
            Write-Verbose "Checking $Global:ServiceName"
            $SvcUsers = &"$AccessChkExe" -c $ServiceList[$i] -w -nobanner
            $SvcUsersLen = $SvcUsers.Length
            $Global:StepNumber++
            For($j = 1 ; $j -lt $SvcUsersLen ; $j++){
                if($SvcUsers[$j] -match $User){
                    $Null = $WriteableServices.Add($ServiceList[$i])
                    $Global:FoundCount++
                    Write-Verbose "Service $Global:ServiceName WRITEABLE by $User"
                }
            }
            if( $NoProgress -eq $False ) { AutoUpdateProgress }
        }
        
        return $WriteableServices
    }catch [Exception]{
        [System.Management.Automation.ErrorRecord]$Record = $_
        $formatstring = "{0}`n{1}"
        $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
        $ExceptMsg=($formatstring -f $fields)  
        $Global:ErrorCount++
        $null=$Global:ErrorList.Add($ExceptMsg) 
    }

}

# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjCQ5Xh55RVYWDSFvciEvBUSI
# /xKgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUdBvjDEjfIgmYAhfG9zIa
# KybTBYkwDQYJKoZIhvcNAQEBBQAEggEAwx/Bk71nBGUzSNrwJZKF1D8e9BpUhwmi
# POuXOiDwIO89u25Zvq2+wvn4dqe+4amzu7lsepOGeM52GWiMN+1iRk1IV0r9BjsF
# psH6rWm31dpKJKHXA5Cd/NbYjCvhjdMKVOxWSi524cW4U7vsqJeRe7sZgqaYUO7T
# SwSmi4pzNP5T6Vsk2mhrG1V1sj1hKrtniRnRGf4Yt8B+AnP0hPk0TwXBVuiQZOVN
# CGVaefRWkFgzKqAmKXduZ4vlH++5v0hn46HOtbEwcxyOYVIw317ZzqRxPHzbLDUk
# n7qGOsS4Vgq3lnfZJVHxQvCEqlwusMQqhBn03MNYeJiK5xzBcRFqgQ==
# SIG # End signature block
