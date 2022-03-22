<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.Core            
  ║   
  ║   miscelaneous.ps1: misc functs
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>





function New-RandomFilename{
<#
    .SYNOPSIS
            Create a RandomFilename 
    .DESCRIPTION
            Create a RandomFilename 
#>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Path = "$ENV:Temp",
        [Parameter(Mandatory=$false)]
        [string]$Extension = 'tmp',
        [Parameter(Mandatory=$false)]
        [int]$MaxLen = 6,
        [Parameter(Mandatory=$false)]
        [switch]$CreateFile,
        [Parameter(Mandatory=$false)]
        [switch]$CreateDirectory
    )    
    try{
        if($MaxLen -lt 4){throw "MaxLen must be between 4 and 36"}
        if($MaxLen -gt 36){throw "MaxLen must be between 4 and 36"}
        [string]$filepath = $Null
        [string]$rname = (New-Guid).Guid
        Write-Verbose "Generated Guid $rname"
        [int]$rval = Get-Random -Minimum 0 -Maximum 9
        Write-Verbose "Generated rval $rval"
        [string]$rname = $rname.replace('-',"$rval")
        Write-Verbose "replace rval $rname"
        [string]$rname = $rname.SubString(0,$MaxLen) + '.' + $Extension
        Write-Verbose "Generated file name $rname"
        if($CreateDirectory -eq $true){
            [string]$rdirname = (New-Guid).Guid
            $newdir = Join-Path "$Path" $rdirname
            Write-Verbose "CreateDirectory option: creating dir: $newdir"
            $Null = New-Item -Path $newdir -ItemType "Directory" -Force -ErrorAction Ignore
            $filepath = Join-Path "$newdir" "$rname"
        }
        $filepath = Join-Path "$Path" $rname
        Write-Verbose "Generated filename: $filepath"

        if($CreateFile -eq $true){
            Write-Verbose "CreateFile option: creating file: $filepath"
            $Null = New-Item -Path $filepath -ItemType "File" -Force -ErrorAction Ignore 
        }
        return $filepath
        
    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
}


function Invoke-FindAndReplace{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (     
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Function Name")]
        [string]$Search,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Function Name")]
        [string]$Path='',         
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Function Name")]
        [string]$Filter='*',          
        [Parameter(Mandatory=$false, ValueFromPipeline=$true,  HelpMessage="Function Name")]
        [string]$Replace='',
        [Parameter(Mandatory=$false, ValueFromPipeline=$true,  HelpMessage="Function Name")]
        [switch]$Recurse        
    ) 

    if($Path -eq ''){$Path = (Get-Location).Path ; }
    $Files = (gci -Path $Path -File -Recurse:$Recurse -Filter "$Filter").Fullname
    $FileCount = $Files.Count

    if($FileCount -eq 0){ throw "no files found with filter $Filter in $Path"; }
    ForEach($file in $Files){
        Write-Verbose "Searching in $file for $Search "
        $content = (Get-Content $file)
        $res =  $content | Select-String -Pattern "$Search" -List -Raw
        $FoundInst = $res.Count

        if($FoundInst -gt 0){
            $res
            Write-Output "Found $FoundInst Instances in $file"
            if($Replace -ne ''){
                Write-Output "Replace in $file. $Search to $Replace"
                
                $content = $content.Replace($Search,$Replace)
                $content  | Set-Content $file
            }else{
                
            }
        }
    }    
}

function Get-FunctionSource{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0, HelpMessage="Function Name")]
        [string]$Name
    ) 
    $IsFunction = $True
    $CmdType = Get-Command $Name
    if($CmdType -eq $Null){ return }
    $CmdType = (Get-Command $Name).CommandType
    $Script = ""
    try{
        $Script = (Get-Item function:$Name -ErrorAction Stop).ScriptBlock
    }
    catch{
        $IsFunction = $False
    }
    
    write-host -n -f DarkYellow "Command Type  : " ;
    write-host -f DarkRed "$CmdType" ;

    if(($IsFunction -eq $False)-Or($CmdType -eq 'Alias')){
        $AliasInfo = (Get-Alias $Name).DisplayName
        write-host -n -f DarkYellow "Alias Info : " ;
        write-host -f DarkRed "$AliasInfo" ;     
        $AliasDesc = (Get-Alias $Name).Description
        write-host -n -f DarkYellow "Alias Desc : " ;
        write-host -f DarkRed "$AliasDesc" ;   
    }else{
        write-host -n -f DarkYellow "Function Name : " ;
        write-host -f DarkRed "$Name" ;
    }

    return $Script

}


function Invoke-PopupMessage{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0, HelpMessage="Command Name (like cl.exe or LiveTcpUdpWatch.exe)")]
        [string]$Title,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0, HelpMessage="Command Name (like cl.exe or LiveTcpUdpWatch.exe)")]
        [string]$Msg
    ) 

    Register-Assemblies

    $Color = 'DarkOrchid'
    $FontSize = 22
    Show-MessageBox -Content "$Msg" -Title "$Msg" -TitleFontWeight "Bold" -TitleBackground "$Color" -TitleTextForeground Black -TitleFontSize $FontSize -ContentBackground "$Color" -ContentFontSize ($FontSize-10) -ButtonTextForeground 'Black' -ContentTextForeground 'White'
}

function Invoke-PopupImage{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0, HelpMessage="Command Name (like cl.exe or LiveTcpUdpWatch.exe)")]
        [string]$Title
    ) 
    Register-Assemblies

    $Url = "https://raw.githubusercontent.com/arsscriptum/PowerShell.Sandbox/main/Img/black.png" 
    $Source = $ENV:TMP_IMG_PATH
    if($Source -eq $null){
        $Dir = New-TemporaryDirectory
        $Source = Join-Path $Dir '55.jpg'
        $ENV:TMP_IMG_PATH = $Source
        [environment]::SetEnvironmentVariable('TMP_IMG_PATH',"$Source",'Process')
    }
    if(-not(Test-Path $Source)){
        Get-OnlineFileNoCache $Url $Source    
    }
    
    [int]$FontSize = 16
    [string]$Color='DimGray'
    $Image = New-Object System.Windows.Controls.Image
    $Image.Source = $Source
    $Image.Height = [System.Drawing.Image]::FromFile($Source).Height 
    $Image.Width = [System.Drawing.Image]::FromFile($Source).Width 
         
    Show-MessageBox -Content $Image -Title "$Title" -TitleFontWeight "Bold" -TitleBackground "$Color" -TitleTextForeground Black -TitleFontSize $FontSize -ContentBackground "$Color" -ContentFontSize ($FontSize-10) -ButtonTextForeground 'Black' -ContentTextForeground 'White'
}

function Get-CommandSource{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0, HelpMessage="Command Name (like cl.exe or LiveTcpUdpWatch.exe)")]
        [string]$Name
    ) 
     
    $Res = Get-Command $Name -ErrorAction Ignore
    if($Res){
        $Source = $($Res).Source
		if($Source){   
            return "$Source"
		}
        else{
            return (Get-FunctionSource $Name)
        }
    }
	return $Null
}


function Rename-FilesInFolder{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Container) ){
                throw "The Path argument must be a Directory. Files paths are not allowed."
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path,       
        [Parameter(Mandatory=$true,Position=1)]
        [String]$Suffix
    ) 
    try{
        Write-Host "#===============================================================================" -f DarkYellow  
        Write-Host "# PROCESSING $Path" -f DarkRed
        Write-Host "#===============================================================================" -f DarkYellow  

        $TemporaryFiles = (gci -Path $p1 -File).Fullname 
        $TemporaryFilesCount = $TemporaryFiles.Count
        Write-Host "#===============================================================================" -f DarkYellow  
        Write-Host "RENAME QUEUE : $TemporaryFilesCount ITEMS" -f DarkYellow  
        $TemporaryFiles.ForEach({ $name = $_ ;  $base = (Get-Item $name).Basename ; $dir = (Get-Item $name).DirectoryName ;
        $newname = $base + $Suffix ; $newname = Join-Path $dir $newname;
            Write-Host "$name => $newname" -f DarkRed -NoNewLine ;
            try { Rename-Item $name $newname; Write-Host "`t`t[OK]" -f DarkGreen } catch { 
                Write-Host "`t`t[FAILED]" -f DarkRed 
            }
        }) 
    }catch [Exception]{
        Write-Host '[ERROR] ' -f DarkRed -NoNewLine
        Write-Host " $_" -f DarkYellow
        Show-ExceptionDetails($_) -ShowStack
    }
}


function Clear-FolderAndCloseHandle{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Container) ){
                throw "The Path argument must be a Directory. Files paths are not allowed."
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path,    
        [Parameter(Mandatory=$false) ]
        [switch]$Directory,
        [Parameter(Mandatory=$false) ]
        [switch]$CloseHandle
    ) 
    Write-Host "#===============================================================================" -f DarkYellow  
    Write-Host "# CLEARING $Path" -f DarkRed
    Write-Host "#===============================================================================" -f DarkYellow  
    $Hndl=(get-command "handle.exe").Source
    #$Killer=(get-command TASKKILL).Source
    $Killer=(get-command pskill).Source

    if($Directory){
        $TemporaryFiles = (gci -Path $Path -Directory).Fullname ; Sleep 3 ;
    }else{
        $TemporaryFiles = (gci -Path $Path).Fullname ; Sleep 3 ;
    }
    
    $TemporaryFilesCount = $TemporaryFiles.Count
    Write-Host "#===============================================================================" -f DarkYellow  
    Write-Host "DELETE QUEUE : $TemporaryFilesCount ITEMS" -f DarkYellow  
    $TemporaryFiles.ForEach({ $name = $_ ;  $base = (Get-Item $name).Basename ; 
        Write-Host "temp file $base . . . . " -f DarkRed -NoNewLine ;
        try { Remove-Item -Path $name -Recurse -Force -ErrorAction 'Stop'; Write-Host "`t`t[OK]" -f DarkGreen } catch { 
            Write-Host "`t`t[FAILED]" -f DarkRed 
            if($CloseHandle){
                $HRES = &"$Hndl" -a "$name" -nobanner
                if($HRES -eq 'No matching handles found'){ continue ;}
                $Data = $HRES.Split(' ')
                #$x = 0 ; $Data.ForEach({ $val = $_ ;write-verbose "$x => $val" ; $x++})
                $x = $Data.IndexOf('pid:'); $x++ 
                $ProcessID = $Data[$x]
                $Processname = $Data[0]
                Write-Host "file $name locked by $Processname (pid $ProcessID)" -f DarkCyan ;  
                &"$Killer" $Processname         
                   
            } 
        } 
    })       
}



function Split-RepositoryUrl {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Repository Url")]
        [ValidateScript({
            $Uri = [uri]$_
            $Scheme = $Uri.Scheme
            $Hostname = $Uri.Host
            $SegmentCount = $Uri.Segments.Count
            if($SegmentCount -ne 3) { Throw "Invalid Url [segment]" }
            if($Hostname -ne 'github.com') { Throw "Invalid Url [Hostname]" }
            if($Scheme -ne 'https') { Throw "Invalid Url [Scheme]" }
            return $True
        })]
        [Alias('u')] [string] $Url
    )
    try{
        [System.Uri]$Uri = [uri]$Url
        $Scheme = $Uri.Scheme
        $Hostname = $Uri.Host
        $Segments = $Uri.Segments
        $Filename = $Segments[2]
        $Len = $Filename.Length - 4
        $Basename = $Filename.SubString(0,$Len)
        $Extension = $Filename.SubString($Len)
        $AbsoluteUri = $Uri.AbsoluteUri
        [pscustomobject]$obj = @{
            Url = $AbsoluteUri
            Scheme = $Scheme
            Hostname = $Hostname
            Filename = $Filename
            Basename = $Basename
            Extension = $Extension
        }
        return $obj
    } catch {
        Show-ExceptionDetails($_) -ShowStack
    }
}



function Split-Url {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Repository Url")]
        [ValidateScript({
            $Uri = [uri]$_
            $Scheme = $Uri.Scheme
            $Hostname = $Uri.Host
            $SegmentCount = $Uri.Segments.Count
            if($SegmentCount -ne 3) { Throw "Invalid Url [segment]" }
            if($Hostname -ne 'github.com') { Throw "Invalid Url [Hostname]" }
            if($Scheme -ne 'https') { Throw "Invalid Url [Scheme]" }
            return $True
        })]
        [Alias('u')] [string] $Url
    )
    try{
        [System.Uri]$Uri = [uri]$Url
        $Scheme = $Uri.Scheme
        $Hostname = $Uri.Host
        $Segments = $Uri.Segments
        $Filename = $Segments[2]
        $Len = $Filename.Length - 4
        $Basename = $Filename.SubString(0,$Len)
        $Extension = $Filename.SubString($Len)
        $AbsoluteUri = $Uri.AbsoluteUri
        [pscustomobject]$obj = @{
            Url = $AbsoluteUri
            Scheme = $Scheme
            Hostname = $Hostname
            Filename = $Filename
            Basename = $Basename
            Extension = $Extension
        }
        return $obj
    } catch {
        Show-ExceptionDetails($_) -ShowStack
    }
}



function Clear-TemporaryFolder{
    Clear-FolderAndCloseHandle -Path "$ENV:Temp" -CloseHandle
}

function Get-PwshExePath{
    $powershell = Get-Process -Id $PID | Select-Object -ExpandProperty Path
    return $powershell
}


function Deploy-CustomModule{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$false) ]
        [String]$Name,
        [Parameter(Mandatory=$false) ]
        [switch]$Commit,
        [Parameter(Mandatory=$false) ]
        [switch]$Documentation
    ) 
    pushd "$ENV:PSModuleDevelopmentPath"

    $AllMods = (gci . -Directory).Fullname 
    if ($PSBoundParameters.ContainsKey('Name')) {
        $AllMods = (gci . -Directory -Filter "*$Name*").Fullname
    }
    
    $AllModsCount = $AllMods.Count

    Write-Host "BUILD QUEUE : $AllModsCount ITEMS" -f DarkRed  

    $i = 1
    $AllMods | % { $m=$_; $nn = (Get-Item $m).Name ;Write-Host "$i ===> $nn" -f DarkYellow ;  $i++ } 
    sleep 1 ;

    $AllMods | % { $m=$_;pushd $m;write-host -f DarkRed "`nBUILD EVERYTHING IN $m`n" ; if($Documentation){ make -i -d -Documentation; }else{  make -i -d ; }; popd ;} ; 

    if($Commit){
        $AllMods | % { $m=$_;pushd $m;write-host -f DarkRed "COMMIT $m`n" ; git add *; git commit -a -m 'latest' ; git push ; popd ;} ; 

    }
}

function Show-Verbs{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$false) ]
        [Alias('Name' ,'v', 'n','like', 'match')]
        [String]$Verb
    )     
    if ($PSBoundParameters.ContainsKey('Verb')) {
        $Formatted = (Get-Verb | where Verb -match $Verb| sort -Property Verb)
        if($Formatted){
            $FormattedCount = $Formatted.Count
            Write-Host "Found $FormattedCount verbs" -f DarkRed -n
            $Formatted
        }else{
            Write-Host "No verb found" -f DarkRed
        }
        return
    }    
    $Groups = ((Get-Verb) | Select Group -Unique).Group
    $Groups.ForEach({
        $g = $_
        $VerbsCount = (Get-Verb -Group $g).Count 
        $Formatted = Get-Verb| where Group -match $g | sort -Property Verb | fw  -Autosize | Out-String
        Write-Host "Verbs in category " -f DarkRed -n
        Write-Host "$g ($VerbsCount) : `n  " -f Red -n
        Write-Host "$Formatted" -f DarkYellow
    })
}
#===============================================================================
# Profile Functions
#===============================================================================

function Compare-ModulePathAgainstPermission{

    $VarModPath=$env:PSModulePath
    $Paths=$VarModPath.Split(';')

    # 1 -> Retrieve my appartenance (My Groups)
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $groups = $id.Groups | foreach-object {$_.Translate([Security.Principal.NTAccount])}
    $GroupList = @() ; ForEach( $g in $groups){  $GroupList += $g ; }
    Sleep -Milliseconds 500
    # Create Filter (Modify a folder) based on those groups
    $filteracl = {$GroupList.Contains($_.IdentityReference) -and ($_.FileSystemRights.ToString() -match 'Modify')}
    $PathPermissions = @()
    ForEach($dir in $Paths){
        if(-not(Test-Path $dir)){ continue;}
        $i = (Get-Item $dir);
        $PathPermissions += (Get-Acl $i).Access | Where $filteracl  | Select `
                                 @{n="Path";e={$i.fullname}},
                                 @{n="Permission";e={$_.FileSystemRights}}
    }
    return $PathPermissions
}

function Get-UserModulesPath{
    $VarModPath=$env:PSModulePath
    $Paths=$VarModPath.Split(';')
    $PathList = @() ; ForEach( $p in $Paths){  $PathList += $p ; }
    $P1 = Join-Path (Get-Item $Profile).DirectoryName 'Modules'
    if($PathList.Contains($P1) -eq $True){
        return $P1
    }
    $PossiblePaths = Compare-ModulePathAgainstPermission
    if($PossiblePaths.Count -gt 0){
        return $PossiblePaths[0].Path
    }
    return $null
}

function Get-RandomColor{                    
    [CmdletBinding()]
    param()

    $max = [System.ConsoleColor].GetFields().Count - 1
    $color = [System.ConsoleColor](Get-Random -Min 0 -Max $max)
    return $color
}

function Get-AllColors{                    
    [CmdletBinding()]
    param()

    [System.ConsoleColor].GetFields() | %{$_.Name}
}


function Remove-FilesOlderThan{
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Container) ){
                throw "The Path argument must be a Directory. Files paths are not allowed."
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path,        
        [Parameter(Mandatory=$true)]
        [string]$Days,
        [Parameter(Mandatory=$false)]
        [string]$Hours=0,
        [Parameter(Mandatory=$false)]
        [switch]$Recurse        
    )

    [DateTime]$Now = Get-Date
    [DateTime]$Limit = $Now.AddDays(-$Days)
    [DateTime]$Limit = $Limit.AddHours(-$Hours)
    $LimitStr = $Limit.GetDateTimeFormats()[9]
    $ToDelete = [System.Collections.ArrayList]::new()
    $Errors = [System.Collections.ArrayList]::new()
    $CurrentPath = (Get-Location).Path
    $Files = (gci -Path $Path -File -Recurse:$Recurse ).Fullname
    $FilesCount = $Files.Count
    Write-ChannelMessage "Calculating files in $Path, older than $Days days $Hours hours."
    ForEach($file in $Files){
        # CreationTime
        # LastAccessTime
        # LastWriteTime

        $LastWriteTime = (Get-Item $file).LastWriteTime
        if($LastWriteTime -lt $Limit){
            $null = $ToDelete.Add($file)
        }
    }
    $ToDeleteCount  = $ToDelete.Count
    Write-ChannelResult "Found $ToDeleteCount / $FilesCount files" -Warning
    $a=Read-Host -Prompt "Delete $ToDeleteCount files ! Are you sure (y/N)?" ; if($a -notmatch "y") {return;}
    $DeletedFiles = 0
    ForEach($file in $ToDelete){
        try{
            Remove-Item -Path $file -Force -ErrorAction Stop | Out-Null    
            write-host "." -f DarkRed -NoNewLine
            $DeletedFiles++
        }catch{
            $Errors.Add($file)
            write-host "[Error] " -f DarkRed -NoNewLine
            write-host " could not delete $file " -f DarkYellow
        }
    }
    Write-ChannelResult "Deleted $DeletedFiles files" 
    $ErrorsCount  = $Errors.Count
    if($ErrorsCount){
        Write-ChannelResult "$ErrorsCount Errors occured" -Warning    
    }
    
}

function Approve-Verb {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )
     <#
        .Synopsis
            Check if a verb is approved in the list of Microsofts coding standards
        .Parameter Name
            The verb to check        
    #>

    return (Get-Verb).Verb.ToLower().Contains($Name.ToLower())

}

function Get-CoreModuleInformation{

        $ModuleName = $ExecutionContext.SessionState.Module
        $ModuleScriptPath = $ScriptMyInvocation = $Script:MyInvocation.MyCommand.Path
        $ModuleScriptPath = (Get-Item "$ModuleScriptPath").DirectoryName
        $CurrentScriptName = $Script:MyInvocation.MyCommand.Name
        $ModuleInformation = @{
            Module        = $ModuleName
            ModuleScriptPath  = $ModuleScriptPath
            CurrentScriptName = $CurrentScriptName
        }
        return $ModuleInformation
}

function Get-InvocationInformation{
        $GlobalMyInvocation = $Global:MyInvocation.MyCommand.Path
        $ScriptMyInvocation = $Script:MyInvocation.MyCommand.Path
        $CurrentScriptName = $Script:MyInvocation.MyCommand.Name
        $PSScriptRootValue = 'null' ; if($PSScriptRoot) { $PSScriptRootValue = $PSScriptRoot}
        $PSCommandPathValue = 'null' ; if($PSCommandPath) { $PSCommandPathValue = $PSCommandPath}
        $CurrentLocation = ($ExecutionContext.SessionState.Path.CurrentLocation).Path
        $CurrentFileLocation = ($ExecutionContext.SessionState.Path.CurrentFileSystemLocation).Path

        Write-Host "===============================================================================" -f DarkRed
        Write-Host "CURRENT INVOCATION INFORMATION" -f DarkYellow;
        Write-Host "===============================================================================" -f DarkRed    
        Write-Host "Global:MyInvocation`t" -NoNewLine -f DarkYellow ; Write-Host "$GlobalMyInvocation" -f Gray 
        Write-Host "Script:MyInvocation`t" -NoNewLine -f DarkYellow ; Write-Host "$ScriptMyInvocation" -f Gray 
        Write-Host "CurrentScriptName  `t" -NoNewLine -f DarkYellow ; Write-Host "$CurrentScriptName" -f Gray 
        Write-Host "PSScriptRoot       `t" -NoNewLine -f DarkYellow;  Write-Host "$PSScriptRootValue" -f Gray 
        Write-Host "PSCommandPath      `t" -NoNewLine -f DarkYellow;  Write-Host "$PSCommandPathValue" -f Gray 
        Write-Host "CurrentLocation    `t" -NoNewLine -f DarkYellow;  Write-Host "$CurrentLocation" -f Gray 
        Write-Host "CurrentFileLocation`t" -NoNewLine -f DarkYellow;  Write-Host "$CurrentFileLocation" -f Gray 
        Write-Host "===============================================================================" -f DarkRed
        Write-Host "MyInvocation -Scope 0" -f DarkYellow;
        Write-Host "===============================================================================" -f DarkRed   
        (Get-Variable MyInvocation -Scope 0 -ValueOnly) | select *   
        Write-Host "===============================================================================" -f DarkRed
        Write-Host "MyInvocation -Scope 1" -f DarkYellow;
        Write-Host "===============================================================================" -f DarkRed   
        (Get-Variable MyInvocation -Scope 1 -ValueOnly) | select *
        Write-Host "===============================================================================" -f DarkRed
        Write-Host "ExecutionContext.SessionState" -f DarkYellow;
        Write-Host "===============================================================================" -f DarkRed   
        $ExecutionContext.SessionState | select *
}

function Get-CurrentModule{
    $CurrentModule = $ExecutionContext.SessionState.Module
    return $CurrentModule
}



function Initialize-PowershellConfig
{
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    try {
        $DefaultErrorAction = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"

        $Script:CurrentPath = (Get-Location).Path
        $Script:ScriptPath = ''
        if(($Global:MyInvocation) -And ($Global:MyInvocation.MyCommand) -And ($Global:MyInvocation.MyCommand.Path)){
            $Script:ScriptPath  = Split-Path $Global:MyInvocation.MyCommand.Path
        }
        $Script:PwshPath = (Get-Item ((Get-Command pwsh.exe).Source)).DirectoryName
        $Script:RegistryPath = "$ENV:OrganizationHKCU\powershell"
        $Script:Edition=$PSVersionTable.PSEdition.ToString()
        $Script:Version=$PSVersionTable.PSVersion.ToString()
        $Script:Paths = (Get-ModulePath | where Writeable -eq $True).Path
        $Script:DefaultModulePath = ''
        if($Paths.Count -gt 0){
            $DefaultModulePath = $Paths[0]
        }
        Write-Host "===============================================================================" -f DarkRed
        Write-Host "SETUP of Powershell Registry Configuration" -f DarkYellow;
        Write-Host "===============================================================================" -f DarkRed    
        Write-Host "Current Path       `t" -NoNewLine -f DarkYellow ; Write-Host "$Script:CurrentPath" -f Gray 
        Write-Host "Script Path        `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:TermScript" -f Gray 
        Write-Host "Pwsh Install Path  `t" -NoNewLine -f DarkYellow;  Write-Host "$PwshPath" -f Gray 
        Write-Host "Pwsh Version       `t" -NoNewLine -f DarkYellow;  Write-Host "$Version" -f Gray 
        Write-Host "Pwsh Edition       `t" -NoNewLine -f DarkYellow;  Write-Host "$Edition" -f Gray 
        Write-Host "Default Module Path`t" -NoNewLine -f DarkYellow;  Write-Host "$DefaultModulePath" -f Gray 

        $null=New-Item -Path $RegistryPath -Force | Out-Null
        $null=New-RegistryValue $RegistryPath "Version" "$Version" String
        $null=New-RegistryValue $RegistryPath "Edition" "$Edition" String
        $null=New-RegistryValue $RegistryPath "InstallPath" "$PwshPath" String
        $null=New-RegistryValue $RegistryPath "DefaultModulePath" "$DefaultModulePath" String
        $ErrorActionPreference = $DefaultErrorAction 
    }catch [Exception]{
        Write-Host '[ERROR] ' -f DarkRed -NoNewLine
        Write-Host "Powershell Registry Configuration $_" -f DarkYellow
        Show-ExceptionDetails($_) -ShowStack
    }
}



function New-TemporaryDirectory
{
<#
    .SYNOPSIS
        Creates a new subdirectory within the users's temporary directory and returns the path.

    .DESCRIPTION
        Creates a new subdirectory within the users's temporary directory and returns the path.

        The Git repo for this module can be found here: http://aka.ms/PowerShellForGitHub

    .EXAMPLE
        New-TemporaryDirectory
        Creates a new directory with a GUID under $env:TEMP

    .OUTPUTS
        System.String - The path to the newly created temporary directory
#>
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "", Justification="Methods called within here make use of PSShouldProcess, and the switch is passed on to them inherently.")]
    param()

    $parentTempPath = [System.IO.Path]::GetTempPath()
    $tempFolderPath = [String]::Empty
    do
    {
        $guid = [System.Guid]::NewGuid()
        $tempFolderPath = Join-Path -Path $parentTempPath -ChildPath $guid
    }
    while (Test-Path -Path $tempFolderPath -PathType Container)

    Write-Verbose  "Creating temporary directory: $tempFolderPath"
    New-Item -ItemType Directory -Path $tempFolderPath
}

function Write-InteractiveHost
{
<#
    .SYNOPSIS
        Forwards to Write-Host only if the host is interactive, else does nothing.

    .DESCRIPTION
        A proxy function around Write-Host that detects if the host is interactive
        before calling Write-Host. Use this instead of Write-Host to avoid failures in
        non-interactive hosts.

        The Git repo for this module can be found here: http://aka.ms/PowerShellForGitHub

    .EXAMPLE
        Write-InteractiveHost "Test"
        Write-InteractiveHost "Test" -NoNewline -f Yellow

    .NOTES
        Boilerplate is generated using these commands:
        # $Metadata = New-Object System.Management.Automation.CommandMetaData (Get-Command Write-Host)
        # [System.Management.Automation.ProxyCommand]::Create($Metadata) | Out-File temp
#>

    [CmdletBinding(
        HelpUri='http://go.microsoft.com/fwlink/?LinkID=113426',
        RemotingCapability='None')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification="This provides a wrapper around Write-Host. In general, we'd like to use Write-Information, but it's not supported on PS 4.0 which we need to support.")]
    param(
        [Parameter(
            Position=0,
            ValueFromPipeline,
            ValueFromRemainingArguments)]
        [System.Object] $Object,

        [switch] $NoNewline,

        [System.Object] $Separator,

        [System.ConsoleColor] $ForegroundColor,

        [System.ConsoleColor] $BackgroundColor
    )

    begin
    {
        $hostIsInteractive = ([Environment]::UserInteractive -and
            ![Bool]([Environment]::GetCommandLineArgs() -like '-noni*') -and
            ((Get-Host).Name -ne 'Default Host'))
    }

    process
    {
        # Determine if the host is interactive
        if ($hostIsInteractive)
        {
            # Special handling for OutBuffer (generated for the proxy function)
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }

            Write-Host @PSBoundParameters
        }
    }
}


function Get-SHA512Hash
{
<#
    .SYNOPSIS
        Gets the SHA512 hash of the requested string.

    .DESCRIPTION
        Gets the SHA512 hash of the requested string.

        The Git repo for this module can be found here: http://aka.ms/PowerShellForGitHub

    .PARAMETER PlainText
        The plain text that you want the SHA512 hash for.

    .EXAMPLE
        Get-SHA512Hash -PlainText "Hello World"

        Returns back the string "2C74FD17EDAFD80E8447B0D46741EE243B7EB74DD2149A0AB1B9246FB30382F27E853D8585719E0E67CBDA0DAA8F51671064615D645AE27ACB15BFB1447F459B"
        which represents the SHA512 hash of "Hello World"

    .OUTPUTS
        System.String - A SHA512 hash of the provided string
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $PlainText
    )

    $sha512= New-Object -TypeName System.Security.Cryptography.SHA512CryptoServiceProvider
    $utf8 = New-Object -TypeName System.Text.UTF8Encoding
    return [System.BitConverter]::ToString($sha512.ComputeHash($utf8.GetBytes($PlainText))) -replace '-', ''
}


function Invoke-CommandForEach{
[CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]$Command,
        [Parameter(Mandatory=$false)]
        [array]$ArgumentList, 
        [Parameter(Mandatory=$false)]
        [String]$Path, 
        #[Parameter(Mandatory=$true)]
        #[ValidateSet('Directory', 'File')]
        #[String]$Type,
        [Parameter(Mandatory=$false)]
        [ValidateSet('Single', 'Multiple')]
        [String]$InstanceMode,        
        [Parameter(Mandatory=$false)]
        [switch]$Recurse
    )

    if (($PSBoundParameters.ContainsKey('Path'))  -eq $False ) {
        $Path = $PSScriptRoot
    }

    Write-Verbose "Invoke-CommandForEach $Type Path: $Path Recurse: $Recurse"
    Write-Verbose " Command $Command"
    $Objects=(gci -Path $Path -Recurse:$Recurse -File).Fullname

    if($Objects -eq $Null) { throw "INVALID OBJECT SET"; return }
    $ObjectsCount=$Objects.Count
    Write-Verbose "Found $ObjectsCount Objects"

    if (($PSBoundParameters.ContainsKey('InstanceMode'))  -eq $False ) {
        $InstanceMode = 'Multiple'
    }

    Write-Verbose "Invoke-CommandForEach InstanceMode $InstanceMode"
    $CommandArgs = [System.Collections.ArrayList]::new()
    if($InstanceMode -eq 'Multiple'){
        $Objects.ForEach({
            $ObjPath = $_
            $CommandArgs = [System.Collections.ArrayList]::new()
            $Null = $CommandArgs.Add("$ObjPath")
            $startProcessParams = @{
                FilePath               = $Command
                Wait                   = $true
                PassThru               = $true
                NoNewWindow            = $true
                WorkingDirectory       = $PSScriptRoot
                ArgumentList           = $CommandArgs
            }

            $cmdExitCode    = 0
            $cmdId          = 0 
            $cmdName        = ''
            
            Write-Verbose " Start-Process $FilePath $ArgumentList"
            #$cmd = Start-Process @startProcessParams | Out-null
            $cmdExitCode = $cmd.ExitCode
            $cmdId = $cmd.Id 
            $cmdName=$cmd.Name 
            Write-Verbose -Message "ExitCode $cmdExitCode"
        })
    }elseif($InstanceMode -eq 'Single'){
        $Objects.ForEach({
            $ObjPath = $_
            $CommandArgs.Add("$ObjPath")
        })
        Write-Verbose " Start-Process $FilePath $ArgumentList"
        $cmd = Start-Process @startProcessParams | Out-null
        $cmdExitCode = $cmd.ExitCode
        $cmdId = $cmd.Id 
        $cmdName=$cmd.Name 
        Write-Verbose -Message "ExitCode $cmdExitCode"        
    }
}


function New-FunctionDemoForAlexForHimself{

    Write-Host -f DarkBlue -n "[NEW FUNCTION ALEX] "
    Write-Host -f DarkYellow " Bla Bla"

    Write-Host "A FIX" -f DarkYellow

}
