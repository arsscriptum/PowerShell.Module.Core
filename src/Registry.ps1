<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   miscelaneous.ps1: misc functs
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>

function Export-RegistryItem{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true, Position=0)]
        [String]$Path,
        [Parameter(Mandatory = $true, Position=1)]
        [String]$BackupFile     
    )
    $RegExe = (Get-Command reg.exe).Source


    Write-Host "===============================================================================" -f DarkRed
    Write-Host "SAVING REGISTRY VALUES FROM $Path" -f DarkYellow;
    Write-Host "===============================================================================" -f DarkRed    
    Write-Host "Registry Path     `t" -NoNewLine -f DarkYellow ; Write-Host "$Path" -f Gray 
    Write-Host "BackupFile   `t" -NoNewLine -f DarkYellow;  Write-Host "$BackupFile" -f Gray 

    $Result=&"$RegExe" EXPORT "$Path" "$BackupFile" /y

    if($Result -eq 'The operation completed successfully.'){
        Write-Host "SUCCESS `t" -NoNewLine -f DarkGreen;  Write-Host " Saved in $BackupFile" -f Gray 
        $NowStr =  (get-date).GetDateTimeFormats()[12]
        $Content = Get-Content -Path $BackupFile -Raw
        $NewContent = @"
    ;;==============================================================================`
    ;;
    ;;  $Path 
    ;;  EXPORTED ON $NowStr
    ;;==============================================================================
    ;;  Ars Scriptum - made in quebec 2020 <guillaumeplante.qc>
    ;;==============================================================================
"@

        $NewContent += $Content
        Set-Content -Path $BackupFile -Value $NewContent
    }
}


function Test-RegistryValue
{
<#
    .Synopsis
    Check if a value exists in the Registry
    .Description
    Check if a value exists in the Registry
    .Parameter Path
    Value registry path
    .Parameter Entry
    The entry to validate
    .Inputs
    None
    .Outputs
    None
    .Example
    Test-RegistryValue "$ENV:OrganizationHKLM\reddit-pwsh-script" "AccessToken"
    >> TRUE

#>
    param (
        [Parameter(Mandatory = $true, Position=0)]
        [String]$Path,
        [Parameter(Mandatory = $true, Position=1)]
        [Alias('Entry')]
        [ValidateNotNullOrEmpty()]$Name
    )

    if(-not(Test-Path $Path)){
        return $false
    }
    $props = Get-ItemProperty -Path $Path -ErrorAction Ignore
    if($props -eq $Null){return $False}
    $value =  $props.$Name
    if($null -eq $value -or $value.Length -eq 0) { return $false }

    return $true
   
}



function Get-RegistryValue
{
<#
    .Synopsis
    Check if a value exists in the Registry
    .Description
    Check if a value exists in the Registry
    .Parameter Path
    Value registry path
    .Parameter Entry
    The entry to validate
    .Inputs
    None
    .Outputs
    None
    .Example
    Get-RegistryValue "$ENV:OrganizationHKCU\terminal" "CurrentProjectPath" 
    Get-RegistryValue "$ENV:OrganizationHKLM\PowershellToolsSuite\GitHubAPI" "AccessToken"
    >> TRUE

#>
    param (
        [Parameter(Mandatory = $true, Position=0)]
        [String]$Path,
        [Parameter(Mandatory = $true, Position=1)]
        [Alias('Entry')]
        [string]$Name
    )

    if(-not(Test-RegistryValue $Path $Name)){
        return $null
    }
    try {
        $Result=(Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Name)
        return $Result
    }

    catch {
        return $null
    }
   
}




function Set-RegistryValue
{
<#
    .Synopsis
    Add a value in the registry, if it exists, it will replace
    .Description
    Add a value in the registry, if it exists, it will replace
    .Parameter Path
    Path
    .Parameter Name
    Name
    .Parameter Value
    Value 
    .Inputs
    None
    .Outputs
    SUCCESS(true) or FAILURE(false)
    .Example
    Set-RegistryValue "$ENV:OrganizationHKLM\reddit-pwsh-script" "ATestingToken" "blabla"
    >> TRUE

#>
    param (
        [Parameter(Mandatory = $true, Position=0)]
        [String]$Path,
        [Parameter(Mandatory = $true, Position=1)]
        [Alias('Entry')]
        [String]$Name,
        [parameter(Mandatory=$true, Position=2)]
        [String]$Value,
        [Parameter(Mandatory = $false, Position=3)]
        [string]$Type='string'
    )

     if(-not(Test-Path $Path)){
        New-Item -Path $Path -Force  -ErrorAction ignore | Out-null
    }

    try {
        if(Test-RegistryValue -Path $Path -Entry $Name){
            Remove-ItemProperty -Path $Path -Name $Name -Force  -ErrorAction ignore | Out-null
        }
      
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-null
        return $true
    }

    catch {
        return $false
    }
}




function New-RegistryValue
{
<#
    .Synopsis
    Create FULL Registry Path and add value
    .Description
    Add a value in the registry, if it exists, it will replace
    .Parameter Path
    Path
    .Parameter Name
    Name
    .Parameter Value
    Value 
    .Inputs
    None
    .Outputs
    SUCCESS(true) or FAILURE(false)
    .Example
    New-RegistryValue "$ENV:OrganizationHKLM\reddit-pwsh-script" "ATestingToken" "blabla"
    New-RegistryValue "$ENV:OrganizationHKCU\terminal" "CurrentProjectPath" "D:\Development\CodeCastor\network\netlib"
    >> TRUE

#>
    param (
     [Parameter(Mandatory = $true, Position=0)]
     [ValidateNotNullOrEmpty()]$Path,
     [Parameter(Mandatory = $true, Position=1)]
     [Alias('Entry')]
     [ValidateNotNullOrEmpty()]$Name,
     [Parameter(Mandatory = $true, Position=2)]
     [ValidateNotNullOrEmpty()]$Value,
     [Parameter(Mandatory = $true, Position=3)]
     [ValidateNotNullOrEmpty()]$Type
    )

    try {
        if(Test-Path -Path $Path){
            if(Test-RegistryValue -Path $Path -Entry $Name){
                Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction ignore | Out-null
            }
        }
        else{
            New-Item -Path $Path -Force | Out-null
        }

        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type  | Out-null
        
        return $true
    }

    catch {
        return $false
    }
   
}


function Format-RegistryPath
{
<#
    .Synopsis
   Check a registry path validity
    .Parameter Path
    Path
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
     [parameter(Mandatory=$false)]
     [Alias('p')]
     [ValidateNotNullOrEmpty()]
     [string]$Path
    )

    try {
        $ValidHives = @('HKCU','HKLM','HKCR','HKCC','HKUS','HKEY_CLASSES_ROOT','HKEY_CURRENT_USER','HKEY_LOCAL_MACHINE','HKEY_USERS','HKEY_CURRENT_CONFIG')
        $Len = $Path.Length 
        if($Len -lt 5){ return $Null }

        if($Path.StartsWith('Computer\')){
            #$Path = $Path.Trim('Computer\')
            $Path = $Path.SubString(9)
            Write-Verbose "Remove 'Computer\'"
        }
        Write-Verbose "Path id $Path"

        $i = $Path.IndexOf('\')

        $Hive = $Path.SubString(0,$i)
        Write-Verbose "Hive is $Hive"
        $Hive = $Hive.Trim(':')
        Write-Verbose "Trim colon Hive is $Hive"
        if($ValidHives.Contains($Hive) -eq $False) {Write-Verbose "Not in valid hives"; return $Null }
        $HiveLen = $Hive.Length
        $Len = $Path.Length 
        $Path = $Path.SubString($HiveLen)
        Write-Verbose "Path is $Path"
        $Path = $Path.Trim(':','\')
        Write-Verbose "Path is $Path"
        if($Hive -eq 'HKCR'){
            $Hive = 'HKEY_CLASSES_ROOT'
        }elseif($Hive -eq 'HKLM'){
            $Hive = 'HKEY_LOCAL_MACHINE'
        }elseif($Hive -eq 'HKUS'){
            $Hive = 'HKEY_USERS'
        }elseif($Hive -eq 'HKCU'){
            $Hive = 'HKEY_CURRENT_USER'
        }elseif($Hive -eq 'HKCC'){
            $Hive = 'HKEY_CURRENT_CONFIG'
        }

        if($ENV:TestRegistryFormat){
             $Source = "https://raw.githubusercontent.com/arsscriptum/PowerShell.Sandbox/main/Placeholder/img/55.jpg"
            [int]$FontSize = 16
            [string]$Color='DimGray'
            $Image = New-Object System.Windows.Controls.Image
            $Image.Source = $Source
            $Image.Height = [System.Drawing.Image]::FromFile($Source).Height / 8
            $Image.Width = [System.Drawing.Image]::FromFile($Source).Width / 8
                 
            Show-MessageBox -Content $Image -Title "Hive is $Hive" -TitleFontWeight "Bold" -TitleBackground "$Color" -TitleTextForeground Black -TitleFontSize $FontSize -ContentBackground "$Color" -ContentFontSize ($FontSize-10) -ButtonTextForeground 'Black' -ContentTextForeground 'White'        
        }
        Write-Verbose "Hive is $Hive"
        $RegPath = 'Computer\' + $Hive + '\' + $Path
        return $RegPath
        
    }catch {
        return $Null
    }
}

function Start-RegistryEditor
{
<#
    .Synopsis
    Start Reg Edit and go to a key
    .Description
    Start Reg Edit and go to a key
    .Parameter Path
    Path
    .Parameter Clipboard
    Name
#>
    param (
     [parameter(Mandatory=$false)]
     [Alias('p')]
     [string]$Path,
     [parameter(Mandatory=$false)]
     [Alias('c')]
     [switch]$Clipboard
    )

    [string]$LastKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit"
    [string]$LastKeyValue = "LastKey"
    try {
        if($Clipboard){
            $Path = Get-Clipboard -Raw
        }
        $RegPath = Format-RegistryPath "$Path"
        if($RegPath -eq $Null) { throw "Bad Registry Path" }
        Set-RegistryValue "$LastKeyPath" "$LastKeyValue" "$RegPath"      
        $RegEditExe = (Get-Command "regedit.exe").Source
        &"$RegEditExe"
        return
    }catch{
        Show-ExceptionDetails($_) -ShowStack
    }
}


# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjGB9oxKofud09J+8VF7J0wP1
# VtmgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUkBRO3Lbh+e+wCpoEdy/U
# ouAH9FkwDQYJKoZIhvcNAQEBBQAEggEA16pq7qGQqxwbGq7oHFEgrYL+g7W5ixXu
# XP8/jEPynVIXfLcSCFHxFhBq+iOXLA3cD/emW3rvCCCorUnBpSBlPxhNHwqtXWli
# X56OYKqyaFJLKbeh4zvK+wAluKiwmwpaclFhSB9871GYIg7BNxWNJ3J8gJaEqo0k
# epacEyanOY6wXbf6oTPE8KYYNFcpqTYnlSA8Dvu+hM1ZtMEhx7WfuD81ezoNVdZ2
# BdWHo1j+Hksqp4hufrUcgF0gznq9P7SV9gbkG49odthewXA7wLbxMjuAHM/6OLz7
# gcSqrLZPgBKPs9JMAV05Sh48gsTPkifXdoGAGkPNPu9If3zAiF1Z2A==
# SIG # End signature block
