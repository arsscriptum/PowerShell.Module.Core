<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



function Search-Item{

    # Define Parameters
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$String,
        [Parameter(Mandatory=$False,Position=1)]
        [string]$Path="",
        [Parameter(Mandatory=$False)]
        [switch]$Recurse,
        [Parameter(Mandatory=$false)]
        [switch]$Quiet
    )   


    if($Path -eq ""){
        $Path = (Get-Location).Path
    }elseif(-not(Test-Path -Path $Path -PathType Container)){ 
        throw "Invalid Path specified."
    }
    if($Quiet -ne $true){
        Write-Host "Search-Item " -NoNewLine -f White
        Write-Host "Search for a name matching " -f DarkGray -NoNewLine
        Write-Host "$String.`n" -f Gray        
    }


    $ResultsNum = 0
    $Results = [System.Collections.ArrayList]::new()
    $timetaken = Measure-Command -Expression { gci -Path $Path -Recurse:$Recurse | % { $Location = $_.Fullname ; $Name = $_.Name; $Full = $_.Fullname ; $Length = $_.Length ; 
        if(($Location -match $String)-Or($Name -match $String)){
            $HighlightedName = ($Name | Select-String -Pattern $String -SimpleMatch); # TODO : This is a string with the pattern highlighted, but it will not show up in Format-Table
            $ResultsNum = $ResultsNum + 1
            $Details = New-Object PSObject -Property @{
                Name = $HighlightedName
                Location = $Location
                Length = $Length
            }
            $null=$Results.Add($Details)
        }
    }
    if($ResultsNum -eq 0){
        Write-Host "No matches found`n`n"
        return
    }}

    $Sum = $Results | measure-object -property Length -sum
    $TimeSec = $timetaken.TotalSeconds
    $TimeMS = $timetaken.TotalMilliseconds
    Write-Host "`nSearch-Item " -NoNewLine -f White
    Write-Host "Found $ResultsNum matches in $TimeSec,$TimeMS s`n" -f DarkGray -NoNewLine

    $Results | Format-Table -Autosize
    Write-Host "`n"
} 



function Search-Files{

    # Define Parameters
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$String,
        [Parameter(Mandatory=$False,Position=1)]
        [string]$Path="",
        [Parameter(Mandatory=$False)]
        [switch]$Recurse,
        [Parameter(Mandatory=$false)]
        [switch]$Quiet
    )   


    if($Path -eq ""){
        $Path = (Get-Location).Path
    }elseif(-not(Test-Path -Path $Path -PathType Container)){ 
        throw "Invalid Path specified."
    }
    if($Quiet -ne $true){
        Write-Host "Search-Files " -NoNewLine -f White
        Write-Host "Search for a name matching " -f DarkGray -NoNewLine
        Write-Host "$String.`n" -f Gray        
    }


    $ResultsNum = 0
    $Results = [System.Collections.ArrayList]::new()
    try{
    $timetaken = Measure-Command -Expression { gci -Path $Path -Recurse:$Recurse -File -ErrorAction Stop | % { $Location = $_.Fullname ; $Name = $_.Name; $Full = $_.Fullname ; $Length = $_.Length ; 
        if(($Location -match $String)-Or($Name -match $String)){
            $HighlightedName = ($Name | Select-String -Pattern $String -SimpleMatch); # TODO : This is a string with the pattern highlighted, but it will not show up in Format-Table
            $ResultsNum = $ResultsNum + 1
            $Details = New-Object PSObject -Property @{
                Name = $HighlightedName
                Location = $Location
                Length = $Length
            }
            $null=$Results.Add($Details)
        }
    }
    if($ResultsNum -eq 0){
        Write-Host "No matches found`n`n"
        return
    }}
    }catch
    { 
        Write-Host "[ERROR] " -n -f DarkRed ; Write-Host "$_" -f DarkYellow ; 
    }
    $count = $Results.count
    $sum = $Results | measure-object -property Length -sum
    if($sum.sum -ge 1073741824)
        {
        $totalGB = [math]::round($sum.sum/1073741824, 2)
        write-Host "$count files using a total of $totalGB GB"  -f DarkRed
        }
    elseif(($sum.sum -ge 1048576) -and ($sum.sum -lt 1073741824))
        {
        $totalMB = [math]::round($sum.sum/1048576, 2)
        write-Host "$count files using a total of $totalMB MB" -f DarkYellow 
        }
    elseif($sum.sum -lt 1048576)
        {
        $totalKB = [math]::round($sum.sum/1024, 2)
        write-Host "$count files using a total of $totalKB KB"  -f DarkYellow 
        }
    
    $TimeSec = $timetaken.TotalSeconds
    $TimeMS = $timetaken.TotalMilliseconds
    Write-Host "`nSearch-Item " -NoNewLine -f White
    Write-Host "Total Size $Sum" -f DarkGray -NoNewLine
    Write-Host "Found $ResultsNum matches in $TimeSec,$TimeMS s`n" -f DarkGray -NoNewLine

    $Results | Format-Table -Autosize
    Write-Host "`n"
} 




Function Find-Item {
  # Parameters $Path and $SearchString
  param ([Parameter(Mandatory=$true, ValueFromPipeline = $true)][string]$SearchString,
  [Parameter(Mandatory=$false)][string]$Path
  )
  $cnt=0
  if($Path -eq "" -Or $Path -eq $null) { $Path = (Get-Location).Path }
  $timetaken = Measure-Command -Expression { Get-ChildItem -Path $Path -Filter $SearchString -Recurse | %{$cnt++; $f = $_; $fn = $f.Fullname ; Write-Host "$Tab -> $fn" -f Cyan | Out-Default}}
  $TimeSec = $timetaken.TotalSeconds
  $TimeMS = $timetaken.TotalMilliseconds
  Write-Host "-------------------------------------------------------" -ForegroundColor Red
  Write-Host "Found $cnt files in $TimeSec,$TimeMS s" -ForegroundColor Red
}


function Search-Pattern
{
<#
    .SYNOPSIS
            Cmdlet to find in files (grep)
    .DESCRIPTION
            Cmdlet to find in files (grep)
    .PARAMETER Pattern
            What to look for in the files
    .PARAMETER Filter
            File filter
    .PARAMETER Path
            Where to search
    .EXAMPLE
        Find-In-Files.ps1 -Pattern 'create' -Filter '*.ps1'
        Find-In-Files.ps1 -Pattern 'create' -Filter '*.ps1' | Out-Gridview
#>

# Define Parameters
[CmdletBinding()]
Param
(
    [Parameter(Position = 0,Mandatory=$true)]
    [Object]$Pattern,

    [Parameter(Mandatory=$false)]
    [Alias('e')]
    [string]$Extension,

    [Parameter(Mandatory=$false)]
    [Alias('p')]
    [string]$Path,

    [Parameter(Mandatory=$false)]
    [Alias('r')]
    [switch]$Recurse=$true

)   

    Write-Host "Search-Pattern (my grep): looking for a string in files. Path: $Path" -f DarkGreen
    Write-Host "  Pattern: $Pattern" -f DarkGreen

    if($Path -eq $null -Or $Path.Length -eq 0){
        $Path = (Get-Location).Path
    }

    $Filter = '*.*'
    if($Extension -ne $null -And $Extension.Length -gt 0){
        $Filter = '*.' + $Extension
        Write-Host "  Using Extension filter: $Filter" -f DarkGreen
    }

    if($Recurse)
    {
        Write-Host "  Recurse: YES" -f DarkYellow
        Get-ChildItem -Path $Path -Filter $Filter -recurse | Select-String -pattern $Pattern
    }
    else
    {
        Write-Host "  Recurse: NO" -f DarkYellow
        Get-ChildItem -Path $Path -Filter $Filter | Select-String -pattern $Pattern
    }
}

# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7xWhohZKH9NiwDGDjHW/UZXR
# KXOgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU9UQTWmR2ab8wF7r9nV5P
# fZD1HsIwDQYJKoZIhvcNAQEBBQAEggEAdkBPRx1ilvdTsABU9Knlnm3qPaKViGKb
# RRQh8MnXEQvF8bngtFJ45p3tTaSyeMk3mCDKmQldNoz8us15znHMq3mUfa1VTyMn
# 96TRmiiZkpu2gj08WAO5Nt2Cg8EpMRQiQv8oak8TA2JKmbCTf1XwOAIdJ3q1c8CX
# BKiPoAG3z3p3jUHWTu4gCkPEtlBQoctLAyOAQNzkIipQxLZLJJi8IcRK7GIa8Wiu
# jhUeUYZV2XHhpELvr0QK0gI7BeYKTyglDLwsIjRxIc/At3G6K11/+BJPAyoPhtIq
# n3x2eUrEhje+taPzpKHXEStkgrLRRaFjOIGTs6sijYLLSowKnO3Bpw==
# SIG # End signature block
