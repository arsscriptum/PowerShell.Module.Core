<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



function Export-RegistryItem{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true, Position=0)]
        [String]$RegistryPath,
        [Parameter(Mandatory = $true, Position=1)]
        [String]$BackupFile     
    )
    $RegExe = (Get-Command reg.exe).Source


    Write-Host "===============================================================================" -f DarkRed
    Write-Host "SAVING REGISTRY VALUES FROM $RegistryPath" -f DarkYellow;
    Write-Host "===============================================================================" -f DarkRed    
    Write-Host "Registry Path     `t" -NoNewLine -f DarkYellow ; Write-Host "$RegistryPath" -f Gray 
    Write-Host "BackupFile   `t" -NoNewLine -f DarkYellow;  Write-Host "$BackupFile" -f Gray 

    $Result=&"$RegExe" EXPORT "$RegistryPath" "$BackupFile" /y

    if($Result -eq 'The operation completed successfully.'){
        Write-Host "SUCCESS `t" -NoNewLine -f DarkGreen;  Write-Host " Saved in $BackupFile" -f Gray 
        $NowStr =  (get-date).GetDateTimeFormats()[12]
        $Content = Get-Content -Path $BackupFile -Raw
        $NewContent = @"
    ;;==============================================================================`
    ;;
    ;;  $RegistryPath 
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
    Reg-Test-Value "$ENV:OrganizationHKLM\reddit-pwsh-script" "AccessToken"
    >> TRUE

#>
    param (
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Entry
    )

    if(-not(Test-Path $Path)){
        return $false
    }
    try {
        Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Entry -ErrorAction Stop | Out-Null
        return $true
    }

    catch {
        return $false
    }
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
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Entry
    )

    if(-not(Test-Path $Path)){
        return $null
    }
    try {
        $Result=(Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Entry)
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
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Name,
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Value
    )

     if(-not(Test-Path $Path)){
        New-Item -Path $Path -Force  -ErrorAction ignore | Out-null
    }

    try {
        if(Test-RegistryValue -Path $Path -Entry $Name){
            Remove-ItemProperty -Path $Path -Name $Name -Force  -ErrorAction ignore | Out-null
        }
      
        New-ItemProperty -Path $Path -Name $Name -Value $Value -Force | Out-null
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
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Name,
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Value,
     [parameter(Mandatory=$true)]
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

