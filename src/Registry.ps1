
<#
#ฬท๐   ๐๐ก๐ข ๐ข๐๐ก๐๐๐ฃ๐ค๐
#ฬท๐   ๐ตโโโโโ๐ดโโโโโ๐ผโโโโโ๐ชโโโโโ๐ทโโโโโ๐ธโโโโโ๐ญโโโโโ๐ชโโโโโ๐ฑโโโโโ๐ฑโโโโโ ๐ธโโโโโ๐จโโโโโ๐ทโโโโโ๐ฎโโโโโ๐ตโโโโโ๐นโโโโโ ๐งโโโโโ๐พโโโโโ ๐ฌโโโโโ๐บโโโโโ๐ฎโโโโโ๐ฑโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐บโโโโโ๐ฒโโโโโ๐ชโโโโโ๐ตโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐ณโโโโโ๐นโโโโโ๐ชโโโโโ.๐ถโโโโโ๐จโโโโโ@๐ฌโโโโโ๐ฒโโโโโ๐ฆโโโโโ๐ฎโโโโโ๐ฑโโโโโ.๐จโโโโโ๐ดโโโโโ๐ฒโโโโโ
#>


$Global:RegLogEnabled = $False


function Write-RegLog {

    <#
    .SYNOPSIS
        Copy one or 2 files to a destination folder
    .DESCRIPTION
        Copy one or 2 files to a destination folder 
            - if file size is less than pre-defined value (Threshold) 
            - after asking the user for copy confirmation   
       
    .PARAMETER Message (-m)
        Log Message
    .PARAMETER Type 'wrn','nrm','err','don'
        Message Type
            'wrn' : Warning
            'nrm' : Normal
            'err' : Error
            'don' : Done

    .EXAMPLE 
        log "Copied $Src to $Dst" -t 'don'  
        log "$Src ==> $Destination" -t 'wrn'
        log "test error" -t 'err'
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('m')]
        [String]$Message,
        [Parameter(Mandatory=$false)]
        [Alias('t')]
        [ValidateSet('wrn','nrm','err','don')]
        [String]$Type='nrm',
        [Parameter(Mandatory=$false)]
        [Alias('n')]
        [switch]$NoReturn
    )

    if($Global:RegLogEnabled -eq $False){return}
    if( ($PSBoundParameters.ContainsKey('Verbose')) -Or ( $Global:LogVerbose )  ){
        Write-Verbose "$Message"
        return
    }
    switch ($Type) {
        'nrm'  {
            Write-Host -n -f DarkCyan "[REG] " ; if($NoReturn) { Write-Host -n -f DarkGray "$Message"} else {Write-Host -f DarkGray "$Message"}
        }
        'don'  {
            Write-Host -n -f DarkGreen "[DONE] " ; Write-Host -f DarkGray "$Message"  
        }
        'wrn'  {
            Write-Host -n -f DarkYellow "[WARN] " ; Write-Host -f White "$Message" 
        }
        'err'  {
            Write-Host -n -f DarkRed "[ERROR] " ; Write-Host -f DarkYellow "$Message" 
        }
    }
}

New-Alias -Name 'log' -Value 'Write-RegLog' -ErrorAction Ignore -Force


function Get-RegListRootPath{
    return "$ENV:OrganizationHKCU\windows.terminal\tmppaths"
}


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



function Remove-RegistryValue
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
        [String]$Name
    )

 
    try {
        if(Test-RegistryValue -Path $Path -Entry $Name){
            Remove-ItemProperty -Path $Path -Name $Name -Force  -ErrorAction ignore | Out-null
        }
      
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

            $SourceUrl = "https://onebeatblog.files.wordpress.com/2013/04/hiatus.jpg"
            $SourceLocal = "$ENV:MyPictures\standby.jpg"
            if(-not(Test-Path $SourceLocal)){
                Get-OnlineFileNoCache -Url $SourceUrl -Path $SourceLocal
            }
            [int]$FontSize = 16
            [string]$Color='Red'
            $Image = New-Object System.Windows.Controls.Image
            $Image.Source = $SourceLocal
            $Image.Height = [System.Drawing.Image]::FromFile($SourceLocal).Height 
            $Image.Width = [System.Drawing.Image]::FromFile($SourceLocal).Width 
                 
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

function Get-LastIndexForId{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('i')]
        [String]$Id
    )

    $Script:RegistryPath = Get-RegListRootPath

    if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
    $LastId = 0
    $num = 0
    $Found = $True
    While( $Found ){
        $NumId = $Id + "_$num"

        $Found = Test-RegistryValue "$Script:RegistryPath" "$NumId"
        log "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`"  ==> Found $Found"

        if($Found -eq $False){ return $LastId }
        $LastId = $num
        $num++
        
    }
    log "Return $LastId"
    return $LastId
}

function Get-NextIndexForId{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('i')]
        [String]$Id
    )
    $Script:RegistryPath = Get-RegListRootPath

    if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
    $Items = 0
    $num = 0
    $Found = $True
    While( $Found ){
        $NumId = $Id + "_$num"

        $Found = Test-RegistryValue "$Script:RegistryPath" "$NumId"
        log "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`"  ==> Found $Found"
        if($Found -eq $True){ $Items++ }
        $num++
        
    }
    $Ret = $Items 
    log "Return $Ret"
    return $Ret
}

function New-RegListItem{
<#
    .Synopsis
    Add a string, to the list associated to the ID in the registry.
    .Description
    Add a string, to the list associated to the ID in the registry. Get it back with Get-RegListLastItem and Get-RegListItemList
    .Parameter String
    srting
    .Parameter Id
    id
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('Id')]
        [String]$Identifier,
        [Parameter(Mandatory=$true,Position=1)]
        [Alias('Str','s')]
        [String]$String
    )

    $Script:RegistryPath = Get-RegListRootPath

    $i = Get-NextIndexForId "$Identifier"
    log "Get-NextIndexForId `"$Identifier`" ==> $i "
    
    $NumId = $Identifier + "_$i"

    
    log "New-RegistryValue `"$Script:RegistryPath`" `"$NumId`" `"$String`" `"string`""
    $null=New-RegistryValue "$Script:RegistryPath" "$NumId" "$String" "string"


    
}


function Get-RegListLastItem{
<#
    .Synopsis
    Get a string, from the list associated to the ID in the registry
    .Description
    Get a string, from the list associated to the ID in the registry. You can delete it at the same time with Delete arg
    .Parameter Delete
    pop the string (del)
    .Parameter Id
    id
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('Id')]
        [String]$Identifier,
        [Parameter(Mandatory=$false)]
        [Alias('d','Del')]
        [switch]$Delete
    )

    $Script:RegistryPath = Get-RegListRootPath

    try{

        if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
        $i = Get-LastIndexForId "$Identifier"
        log "Get-LastIndexForId `"$Identifier`" ==> $i "
        
        $NumId = $Identifier + "_$i"

        
        log "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`" `"$String`" `"string`""
        $Exists=Test-RegistryValue "$Script:RegistryPath" "$NumId"

        if($Exists){
            $Value = Get-RegistryValue "$Script:RegistryPath" "$NumId"
            if($Delete){
                log "Delete Key..."
                $Null = Remove-RegistryValue "$Script:RegistryPath" "$NumId"
            }
            return $Value
        }else{
            throw "Key doesn't exists"
        }      
    }catch{
        log "$_" -t 'err'
    }

    
}


function Get-RegListItemList{
<#
    .Synopsis
    Get all the strings, from the list associated to the ID in the registry
    .Description
    Get all string, from the list associated to the ID in the registry.
    .Parameter Id
    id
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('i')]
        [String]$Identifier
    )
    $Script:RegistryPath = Get-RegListRootPath

    if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
    $Ret = [System.Collections.ArrayList]::new()
    try{
        $LastId = 0
        $num = 0
        $Found = $True
        While( $Found ){
            $NumId = $Identifier + "_$num"

            $Found = Test-RegistryValue "$Script:RegistryPath" "$NumId"
            log "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`"  ==> Found $Found"

            if($Found -eq $True){  

                $Exists=Test-RegistryValue "$Script:RegistryPath" "$NumId"

                if($Exists){
                    $Value = Get-RegistryValue "$Script:RegistryPath" "$NumId"
                    $Null = $Ret.Add($Value)
                }else{
                    break;
                }
                $num++ 
            }    
        } 
    }catch{
        log "$_" -t 'err'
    }

    return $Ret
    
}



function Remove-RegListItemList{
<#
    .Synopsis
    Delete all the strings, from the list associated to the ID in the registry
    .Description
    Delete all string, from the list associated to the ID in the registry.
    .Parameter Identifier
    id
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('i', 'Id')]
        [String]$Identifier,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="test only")]
        [switch]$Test        
    )
     $TestMode = $False
    if ($PSBoundParameters.ContainsKey('Verbose')) {
        Write-Verbose "Verbose OUTPUT"             
    }
    if ( ($PSBoundParameters.ContainsKey('WhatIf') -Or($PSBoundParameters.ContainsKey('Test')))) {
        Write-Verbose "TEST ONLY"             
        $TestMode = $True
    }
    $Script:RegistryPath = Get-RegListRootPath

    if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
    $Ret = [System.Collections.ArrayList]::new()
    try{
        $LastId = 0
        $num = 0
        $Found = $True
        While( $Found ){
            $NumId = $Identifier + "_$num"

            $Found = Test-RegistryValue "$Script:RegistryPath" "$NumId"
             Write-Verbose "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`"  ==> Found $Found"

            if($TestMode -eq $false){  
                $Null = Remove-RegistryValue "$Script:RegistryPath" "$NumId"
                 Write-Verbose "Remove-RegistryValue `"$Script:RegistryPath`" `"$NumId`""
            }else{
                log "TestMode : would delete `"$Script:RegistryPath`" `"$NumId`" "

                break;
            }
        $num++ 
        }     
    }catch{
        log "$_" -t 'err'
    }

    return $Ret
    
}




function Get-EntriesRecursively {
<#
    .Synopsis
   Check a registry path validity
    .Parameter Path
    Path
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
     [parameter(Mandatory=$true)]
     [string]$Path,
     [parameter(Mandatory=$true)]
     [string]$Name,
     [parameter(Mandatory=$false)]
     [System.Collections.ArrayList]$Results

    )

    try{
        if($Results -eq $Null){
            $Results = [System.Collections.ArrayList]::new()
            Write-Verbose "Created Results"
        }
        $AllChilds=(Get-Item "$Path\*").PSChildName
        $AllChildsCount=$AllChilds.Count

        foreach($Entry in $AllChilds){
            $exists=Test-RegistryValue "$Path\$Entry" "$Name"
            if($exists){
                $Value=(Get-ItemProperty "$Path\$Entry")."$Name"
                Write-Verbose "Found $Name [$Value]"
                [pscustomobject]$o = @{
                    Path = "$Path\$Entry"
                    Name = $Name
                    Value = $Value
                }

                $Null = $Results.Add($o)    
            }

            $c = (Get-Item "$Path\$Entry\*").Count
            if($c -gt 0){
               $Null = Get-EntriesRecursively -Path "$Path\$Entry" -Name $Name -Results $Results
            }
        }
    return $Results
        
    }catch{
        Write-Error "$_"

    }
}






function New-TestEntries {
<#
    .Synopsis
   Check a registry path validity
    .Parameter Path
    Path
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
     [parameter(Mandatory=$false)]
     [string]$Path = "HKCU:\SOFTWARE\DevelopmentSandbox\TestSettings",
     [parameter(Mandatory=$false)]
     [int]$NumEntries = 10,
     [parameter(Mandatory=$false)]
     [int]$MaxDepth = 5,
     [parameter(Mandatory=$false)]
     [switch]$BogusEntries
    )

    try{

    Write-Host "Root Path " -f Red -n ; Write-Host "[$Path]" -f Gray
    New-Item -Path $Path -ItemType 'Directory' -Force  -ErrorAction Ignore | Out-null

    New-PSDrive -Name MySb -PSProvider Registry -Root $Path | Out-null

    Get-Random -SetSeed $(Get-Date -UFormat %s) | Out-null
    $NumEntries = 10

    $Noise = [System.Collections.ArrayList]::new()
    For($i = 0 ; $i -lt $numEntries ; $i++){
        $Depth = Get-Random -Maximum $MaxDepth -Minimum 1

        $p = $Path
        $rel = '/'
        [string]$s = (New-Guid).Guid 
        [string[]]$sa = $s.Split('-') 
        For($j = 0 ; $j -lt $Depth ; $j++){
            $p = Join-Path $p $sa[$j]
            $rel = Join-Path $rel $sa[$j]

            if($BogusEntries){
                $n1 = "Guid_$j"
                $n2 = "Date_$j"
                $v1 = $((New-Guid).Guid)
                $v2 = $((Get-Date).GetDateTimeFormats()[$j])

                New-Item -Path $p -Force | Out-null
                New-ItemProperty -Path $p -Name "Id" -Value $(Get-Random -Maximum 500 -Minimum 1) -PropertyType 'String'  | Out-null
                New-ItemProperty -Path $p -Name $n1 -Value $v1 -PropertyType 'String'  | Out-null
                New-ItemProperty -Path $p -Name $n2 -Value $v2 -PropertyType 'String'  | Out-null

                Write-Verbose "`t+$p"
                Write-Verbose "`t===> $n1 / $v1"
                Write-Verbose "`t===> $n2 / $v2"
           
                $Null = $Noise.Add(@{
                    Path = $p
                    Name = $n1
                    Value = $v1
                })
                $Null = $Noise.Add(@{
                    Path = $p
                    Name = $n2
                    Value = $v2
                })
            }

        }


        $Name = 'IP Address'
        $Value = "192.168.$(Get-Random -Maximum 255 -Minimum 1).$(Get-Random -Maximum 255 -Minimum 1)" ; 
        $Type = 'String'

        if($(Get-Random -Maximum 20 -Minimum 1) -gt 10){
            $Value = "192.168.$(Get-Random -Maximum 255 -Minimum 1).$(Get-Random -Maximum 255 -Minimum 1)" ; 
        }else{
            $Value = "10.0.$(Get-Random -Maximum 100 -Minimum 1).$(Get-Random -Maximum 255 -Minimum 1)" ;
        }
        
        New-Item -Path $p -Force | Out-null
        New-ItemProperty -Path $p -Name $Name -Value $Value -PropertyType $Type  | Out-null
        New-ItemProperty -Path $p -Name "Id" -Value $(Get-Random -Maximum 500 -Minimum 1) -PropertyType 'String'  | Out-null
            
        Write-Host "+ $Name / " -n -f Blue
        Write-Host "$Value" -n -f Yellow
        Write-Host "`t`t[$rel]" -f Gray
    }

    if($BogusEntries){
        Write-Host -f DarkYellow "+ BOGUS ENTRIES : $($Noise.Count)"
        
    }
    Write-Host -f DarkYellow "+ TOTAL ENTRIES : $((gci -Path $Path -Recurse).Count)"
    

    }catch{
        Write-Error "$_"

    }

    Remove-PSDrive -Name MySb
}

