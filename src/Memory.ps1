<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

##===----------------------------------------------------------------------===
##  MEmory.ps1 - PowerShell script for memory usage data
##===----------------------------------------------------------------------===
 
function Get-ProcessMemoryUsage
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$ProcessName
    )
    $ErrorActionPreference = 'Ignore'
    try {
        [array]$prcs = Get-Process "$ProcessName"

        if($prcs -eq $Null) { throw "No Such Process" }
        #"Write-Host "===============================================================================" -f DarkRed
        #Write-Host "MEMORY USAGE FOR $ProcessName" -f DarkYellow;
        #$Data = $Process | Group-Object -Property ProcessName | Format-Table Name, Count, @{n='Mem (KB)';e={'{0:N0}' -f (($_.Group|Measure-Object WorkingSet -Sum).Sum / 1KB)};a='right'} -AutoSize
        $NumProcess =$prcs.Length
        $MemoryKb = $prcs | Group-Object -Property ProcessName | % {  (($_.Group|Measure-Object WorkingSet -Sum).Sum / 1KB) }
        $MemoryMb = $prcs | Group-Object -Property ProcessName | % {  (($_.Group|Measure-Object WorkingSet -Sum).Sum / 1MB) }
        [pscustomobject]$ret = [PSCustomObject]@{
            Name = $ProcessName
            Count = $NumProcess
            MemoryKb = $MemoryKb
            MemoryMb = $MemoryMb
        }
        return $ret
    }
    catch {
        Write-Host '[ProcessMemoryUsage] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}
 
function Get-MemoryUsageForAllProcesses
{
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $ErrorActionPreference = 'Ignore'
    try {
        $high = 0
        $pmemhigh = $null
        $ProcessList = (Get-Process | Group-Object -Property ProcessName).Name
        $MemoryUsage = [System.Collections.ArrayList]::new()
        ForEach($p in $ProcessList){
            [PSCustomObject]$pmem = Get-ProcessMemoryUsage $p
            $MemoryUsage.Add($pmem) | Out-Null
            $memUsage = $pmem.MemoryKb
            if($memUsage -gt $high){
                $high = $memUsage
                $pmemhigh = $pmem
            }

        }
        Write-Verbose "Highest $pmemhigh"
        return $MemoryUsage | Sort MemoryKb -Descending
    }
    catch {
        Write-Host '[MemoryUsageForAllProcesses] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}

function Get-TopMemoryUsers
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $False)]
        [int]$Num = 5
    )
    $ErrorActionPreference = 'Ignore'
    try {
        Get-CimInstance -ClassName  WIN32_PROCESS | Sort-Object -Property ws -Descending | Select-Object -first $Num processname, @{Name="Mem Usage(MB)";Expression={[math]::round($_.ws / 1mb)}},@{Name="ProcessId";Expression={$_.ProcessId}}
   }
    catch {
        Write-Host '[TopMemoryUsers] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}


function Get-MemoryUser
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [string]$Name
    )
    $ErrorActionPreference = 'Ignore'
    try {
        Write-Host '[MemoryUser] ' -n -f DarkRed
        Write-Host "for $Name : PARSING.... `nPlease wait...." -f DarkYellow

        $List = Get-CimInstance -ClassName  WIN32_PROCESS | Sort-Object -Property ws -Descending | Select-Object processname, @{Name="Mem Usage(MB)";Expression={[math]::round($_.ws / 1mb)}},@{Name="CmdLine";Expression={Get-ProcessCmdLineById $_.ProcessId}},@{Name="ProcessId";Expression={$_.ProcessId}}
        $List = $List | where ProcessName -match "$Name"
        $List
   }
    catch {
        Write-Host '[TopMemoryUsers] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}


function Get-ProcessCmdLineById
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [int]$ProcessId
    )
    $cmdline = (Get-CimInstance Win32_Process -Filter "ProcessId = '$ProcessId'" | select CommandLine ).CommandLine    
    return $cmdline
}

function Get-ProcessCmdLine
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$ProcessName
    )
    $ErrorActionPreference = 'Ignore'
    try {
        [array]$prcs = Get-Process "$ProcessName"

        if($prcs -eq $Null) { throw "No Such Process" }
        #"Write-Host "===============================================================================" -f DarkRed
        #Write-Host "MEMORY USAGE FOR $ProcessName" -f DarkYellow;
        #$Data = $Process | Group-Object -Property ProcessName | Format-Table Name, Count, @{n='Mem (KB)';e={'{0:N0}' -f (($_.Group|Measure-Object WorkingSet -Sum).Sum / 1KB)};a='right'} -AutoSize
        $NumProcess =$prcs.Length
        $PInfo = [System.Collections.ArrayList]::new()
        $prcs.ForEach({ $p = $_;
            $pname = $p.Name
            $processid = $p.Id
            $PMem = $p.WorkingSet
            $cmdline = (Get-CimInstance Win32_Process -Filter "ProcessId = '$processid'" | select CommandLine ).CommandLine
            [pscustomobject]$Obj = [PSCustomObject]@{
                Name = $pname
                ProcessId = $processid
                CmdLine = $cmdline
                MemoryMb = $PMem
            }
            $PInfo.Add($Obj)
            })
        return $PInfo
    }
    catch {
        Write-Host '[ProcessMemoryUsage] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPqmD6vDKLym6lnEkx9+He6ry
# SRagggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUCl/JwkGL9k0Xf8ScEcq3
# OkJvBc0wDQYJKoZIhvcNAQEBBQAEggEADOkgsl2Vnmbchn8XaRFFZI2hXZXVLjGO
# bzZtKrBT4y0VrUzsJNugM1UaQIKfo0WdM25r/J3fgPgDWMSkOMuhPCebeBr6yF0D
# b3sfPXZmKsFlPM09qe2wD44NwpRfth/CuSWw6sC5veBgO3mBPfjAUbs87bNISlci
# GDPY1pf1RE6ZfgyTEq5FSG02v1W/Am1eiQq7y8FTPWkk7zFKEYKM7qFlituuCt2d
# Gw0mPDntXnwiCt8oX+BBMGK91IOE/OAbKLAwyzsTtza/2dumjqimxTzCw6SdBtrZ
# uJHZk2Wg7O9zoNcpvuCR1tqnjnm5+/l+5GJe1FViJXE9ByEAOd4M+A==
# SIG # End signature block
