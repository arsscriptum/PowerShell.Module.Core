<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


Function ShouldCreateFolder($Folder){
    $yeah = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Description."
    $nah = New-Object System.Management.Automation.Host.ChoiceDescription "&No exit","Description."
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yeah, $nah)
    $mess = "Create Destination Folder ($Folder) ?"
    $rslt = $host.ui.PromptForChoice('', $mess, $options, 1)
    
    return ($rslt -eq 0)
}

function Invoke-ForEachChilds
{
<#
    .SYNOPSIS
            Cmdlet to find in files (grep)
    .DESCRIPTION
            Cmdlet to find in files (grep)
    .PARAMETER Path

#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Command
    ) 
    
    $CurrentPath = ( Get-Location ).Path
    $Childs = (gci -Path $CurrentPath -Directory).Fullname
    $Childs.ForEach({
        $Dir = $_
        pushd $Dir
        &"$Command"
        popd

        })

}


function New-Directory
{
<#
    .SYNOPSIS
            Cmdlet to find in files (grep)
    .DESCRIPTION
            Cmdlet to find in files (grep)
    .PARAMETER Path

#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Path
    ) 
    $Null= Remove-Item $Path -Recurse -Force -EA Ignore
    return (New-Item $Path -Force -EA Ignore -ItemType Directory)
}

function Resolve-UnverifiedPath
{
<#
    .SYNOPSIS
        A wrapper around Resolve-Path that works for paths that exist as well
        as for paths that don't (Resolve-Path normally throws an exception if
        the path doesn't exist.)

    .DESCRIPTION
        A wrapper around Resolve-Path that works for paths that exist as well
        as for paths that don't (Resolve-Path normally throws an exception if
        the path doesn't exist.)

        The Git repo for this module can be found here: https://aka.ms/PowerShellForGitHub

    .EXAMPLE
        Resolve-UnverifiedPath -Path 'c:\windows\notepad.exe'

        Returns the string 'c:\windows\notepad.exe'.

    .EXAMPLE
        Resolve-UnverifiedPath -Path '..\notepad.exe'

        Returns the string 'c:\windows\notepad.exe', assuming that it's executed from
        within 'c:\windows\system32' or some other sub-directory.

    .EXAMPLE
        Resolve-UnverifiedPath -Path '..\foo.exe'

        Returns the string 'c:\windows\foo.exe', assuming that it's executed from
        within 'c:\windows\system32' or some other sub-directory, even though this
        file doesn't exist.

    .OUTPUTS
        [string] - The fully resolved path

#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string] $Path
    )

    process
    {
        $resolvedPath = Resolve-Path -Path $Path -ErrorVariable resolvePathError -ErrorAction SilentlyContinue

        if ($null -eq $resolvedPath)
        {
            Write-Output -InputObject ($resolvePathError[0].TargetObject)
        }
        else
        {
            Write-Output -InputObject ($resolvedPath.ProviderPath)
        }
    }
}

function Approve-Directory
{
<#
    .SYNOPSIS
        A utility function for ensuring a given directory exists.

    .DESCRIPTION
        A utility function for ensuring a given directory exists.

        If the directory does not already exist, it will be created.

    .PARAMETER Path
        A full or relative path to the directory that should exist when the function exits.

    .NOTES
        Uses the Resolve-UnverifiedPath function to resolve relative paths.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "", Justification = "Unable to find a standard verb that satisfies describing the purpose of this internal helper method.")]
    param(
        [Parameter(Mandatory)]
        [string] $Path
    )

    try
    {
        $Path = Resolve-UnverifiedPath -Path $Path

        if (-not (Test-Path -PathType Container -Path $Path))
        {
            Write-Verbose "Creating directory: [$Path]" 
            New-Item -ItemType Directory -Path $Path | Out-Null
        }
    }
    catch
    {
        Write-Verbose "Could not Approve directory: [$Path]"

        throw
    }
}

function AutoUpdateProgress {   # NOEXPORT
    $Len = $Global:Channel.Length
    $Diff = 50 - $Len
    For($i = 0 ; $i -lt $Diff ; $i++){ $Global:Channel += '.'}
    $Global:ProgressMessage = "Clearing $Global:Channel... ( $Global:StepNumber on $Global:TotalSteps) ERRORS $Global:ErrorCount"
    Write-Progress -Activity $Global:ProgressTitle -Status $Global:ProgressMessage -PercentComplete (($Global:StepNumber / $Global:TotalSteps) * 100)

}

function Sync-Folders
{
<#
    .SYNOPSIS
            Cmdlet to find in files (grep)
    .DESCRIPTION
            Cmdlet to find in files (grep)
    .PARAMETER Path

#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Folder1,
        [Parameter(Mandatory=$True,Position=1)]
        [string]$Folder2
    )  

    $FldrL=(Get-Item -Path $Folder1).FullName
    $FldrR=(Get-Item -Path $Folder2).FullName

    Write-Host "Preparing to copy $($FldrL) to $($FldrR)"
    $LeftItems = Get-ChildItem -Recurse -Path $FldrL
    $RightItems = Get-ChildItem -Recurse -Path $FldrR

    $Result = Compare-Object -ReferenceObject $LeftItems -DifferenceObject $RightItems -IncludeEqual

    foreach ($Folder in $Result) {
        $CopyFile = $false
    $CopyLeft = $false
    $CopyRight = $false
        if ($Folder.SideIndicator -eq "==")
        {
            $LeftPath = $Folder.InputObject.FullName
            $RightPath = $Folder.InputObject.FullName.Replace($FldrL, $FldrR)
          
            if (Test-Path $LeftPath)
            {
                if (Test-Path $RightPath)
                {

                    $LeftDate = [datetime](Get-ItemProperty -Path $LeftPath -Name LastWriteTime).LastWriteTime
                $RightDate = [datetime](Get-ItemProperty -Path $RightPath -Name LastWriteTime).LastWriteTime

                    if ((Get-Item $LeftPath).GetType().Name -eq "FileInfo")
                    {
                        if ($LeftDate -gt $RightDate)
                        {
                            $SourcePath = $LeftPath
                            $TargetPath = $RightPath
                            $CopyFile = $true
                        }
                        if ($RightDate -gt $LeftDate)
                        {
                            $SourcePath = $RightPath
                            $TargetPath = $LeftPath
                            $CopyFile = $true
                        }
                    }
                } else {
                    $CopyLeft = $true
                }
            } else {
                if (Test-Path $RightPath)
                {
                    $CopyRight = $true
                }
           }
        }
        if ($Folder.SideIndicator -eq "<=" -or $CopyLeft) {
            $SourcePath = $Folder.InputObject.FullName
            $TargetPath = $Folder.InputObject.FullName.Replace($FldrL, $FldrR)
            $CopyFile = $true
        }
        if ($Folder.SideIndicator -eq "=>" -or $CopyRight) {
            $SourcePath = $Folder.InputObject.FullName
            $TargetPath = $Folder.InputObject.FullName.Replace($FldrR, $FldrL)
            $CopyFile = $true
        }

        try 
        {
            if ($CopyFile -And (Test-Path $SourcePath))
            {
                Write-Host "$($Folder.SideIndicator) Copying $($SourcePath) to $($TargetPath)"
                New-Item -ItemType Directory -Path $TargetPath -Force

                if ((Get-Item $SourcePath).GetType().Name -eq "DirectoryInfo")
                {
                    New-Item -Path $TargetPath -ItemType Directory -Force
                }
                else
                {
                    Copy-Item -Path $SourcePath -Destination $TargetPath -Force | Out-null
                }
            }
        }catch{
            Show-ExceptionDetails($_) -ShowStack
        }
    }
}

function Invoke-IsAdministrator  {  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

function Sync-Directories {
    <#
    .SYNOPSIS
        Copy a directory to a destination directory using ROBOCOPY.
    .DESCRIPTION
        Backup a directory will copy all te files from the source directory but will not remove missing files
        on a second iteration, like a MIRROR/SYNC would   
    .DESCRIPTION
        Invoke ROBOCOPY to copy files, a wrapper.
    .PARAMETER Source
        Source Directory (drive:\path or \\server\share\path).
    .PARAMETER Destination
        Destination Dir  (drive:\path or \\server\share\path).
    .PARAMETER SyncType 
        One of the following operating procedures:
        'MIR'    ==> MIRror a directory tree (equivalent to /E plus /PURGE), delete dest files/dirs that no longer exist in source.
        'COPY'   ==> It will leave everything in destination, but will add new files fro source, usefull to merge 2 folders
        'NOCOPY' ==> delete dest files/dirs that no longer exist in source. do not copy new, keep same.
        Default  ==> MIRROR
    .PARAMETER Log
        Log File name
    .PARAMETER BackupMode
        copy files in restartable mode.; if access denied use Backup mode.
        Requires Admin privileges to add user rights.        
    .PARAMETER Test
        Simulation: dont copy (like what if, but will call Start-Process)        
    .EXAMPLE 
       Sync-Directories $dst $src -SyncType 'NOCOPY'
       Sync-Directories $src $dst -SyncType 'MIRROR' -Verbose
       Sync-Directories $src $dst -Test
#>

    [CmdletBinding()]
    param(
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
        [Alias('s', 'src')]
        [String]$Source,
        [Parameter(Mandatory=$true,Position=1)]
        [Alias('d', 'dst')]
        [String]$Destination,
        [Parameter(Mandatory=$false)]
        [Alias('t', 'type')]
        [ValidateSet('MIRROR', 'COPY', 'NOCOPY')]
        [string]$SyncType,        
        [Parameter(Mandatory=$false)]
        [Alias('l')]
        [String]$Log="",
        [Parameter(Mandatory=$false)]
        [Alias('b')]
        [switch]$BackupMode,
        [Parameter(Mandatory=$false)]
        [switch]$Test        
        
    )

    try{

        # throw errors on undefined variables
        Set-StrictMode -Version 1

        if($BackupMode)
        {
            if(-not (Invoke-IsAdministrator)) { throw "Backup mode requires Admin privileges to change user rights" }
            Write-Host '[ROBOCOPY] ' -f Blue -NoNewLine
            Write-Host "Enabling Privilege SeBackupPrivilege" -f Yellow            
            [void][TokenManipulator]::AddPrivilege("SeBackupPrivilege")
            Write-Host '[ROBOCOPY] ' -f Blue -NoNewLine
            Write-Host "Enabling Privilege SeRestorePrivilege" -f Yellow            
            [void][TokenManipulator]::AddPrivilege("SeRestorePrivilege")           
        }
        # make sure the given parameters are valid paths

        if (-Not (Test-Path $Destination)) {
            if((ShouldCreateFolder $Destination) -eq $True){
                New-Item -Path $Destination -ItemType Directory -Force -ErrorAction Ignore | Out-null   
                Write-Host '[ROBOCOPY] ' -f Blue -NoNewLine
                Write-Host "creating $Destination " -f Gray
            }else {
               throw "Destination Path $Destination Non-Existent"
            }   
        } 
        $Source  = Resolve-Path $Source
        $Destination = Resolve-Path $Destination
        $ROBOCOPY = (Get-Command 'robocopy.exe').Source

        if($Log -ne ""){
            New-Item -Path $Log -ItemType File -Force -ErrorAction ignore | Out-Null
        }

        if (-Not (Test-Path -Type Container $Source))  { throw "not a container: $Source"  }
        if (-Not (Test-Path -Type Container $Destination)) { throw "not a container: $Destination" }
        if (-Not (Test-Path -Type Leaf $ROBOCOPY)) { throw "cannot find ROBOCOPY: $ROBOCOPY" }

        Write-Host '[ROBOCOPY] ' -f Blue -NoNewLine
        Write-Host "start sync $Source ==> $Destination`n`tMULTI-THERADED (8 threads)`n`t1 FAILURE ALLOWED`n`tCREATE DIRECTORY STRUCTURE`n" -f Gray
        $ArgumentList = "$Source $Destination /MT:8 /R:1 /W:1 /BYTES /FP /X"

        if ($PSBoundParameters.ContainsKey('Verbose')) {
            Write-Host '[ROBOCOPY] ' -f DarkRed -NoNewLine
            Write-Host "Verbose OUTPUT" -f Yellow            
            $ArgumentList += " /V"
        }

        if (($PSBoundParameters.ContainsKey('Test')) -Or ($Test)) {
            Write-Host '[ROBOCOPY] ' -f DarkRed -NoNewLine
            Write-Host "Test : Simulation; List only - don't copy, timestamp or delete any files." -f Yellow            
            $ArgumentList += " /L"
        }


        if ($PSBoundParameters.ContainsKey('SyncType')) {
            if($SyncType -eq 'MIRROR'){
                $ArgumentList += " /MIR"
                Write-Host '[ROBOCOPY] ' -f Blue -NoNewLine
                Write-Host "`n`tMIRRORING : FILES WILL BE REMOVED OR ADDED TO BE N SYNC" -f Yellow
            }elseif($SyncType -eq 'COPY'){

                $ArgumentList += " /COPY:DAT /E"
                Write-Host '[ROBOCOPY] ' -f Blue -NoNewLine
                Write-Host "`n`tCOPY ALL file info. copy subdirectories, including Empty ones." -f Yellow
            }elseif($SyncType -eq 'NOCOPY'){
                $ArgumentList += " /PURGE /NOCOPY "
                Write-Host '[ROBOCOPY] ' -f Blue -NoNewLine
                Write-Host "`n`tNOCOPY" -f Yellow
            }else{
                throw "INVALID COPY TYPE"
            }
           
        }else{
            $ArgumentList += " /MIR "      
        }

        # Instantiate and start a new stopwatch
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        if($BackupMode){
             $ArgumentList += " /ZB"
        }
        if($Log -ne ""){
            $ArgumentList += " /LOG:$Log"
        }
        $process = Start-Process -FilePath $ROBOCOPY -ArgumentList $ArgumentList -Wait -NoNewWindow -PassThru
      
        $handle = $process.Handle # cache proc.Handle
        $null=$process.WaitForExit();

        # This will print out False/True depending on if the process has ended yet or not
        # Needs to be called for the command below to work correctly
        $null=$process.HasExited
        $ProcessExitCode = $process.ExitCode

        [int]$elapsedSeconds = $stopwatch.Elapsed.Seconds
        $stopwatch.Stop()

        Write-Host "[ROBOCOPY] " -f Blue -NoNewLine
        Write-Host "COMPLETED IN $elapsedSeconds seconds" -f Gray
        if($Log -ne ""){
            $LogStr = Get-Content $Log -Raw
            Write-Host "[ROBOCOPY] " -f Blue -NoNewLine
            Write-Host "$LogStr " -f Yellow
        }
        $returnCodeMessage = @{
            0x00 = "[INFO]: No errors occurred, and no copying was done. The source and destination directory trees are completely synchronized."
            0x01 = "[INFO]: One or more files were copied successfully (that is, new files have arrived)."
            0x02 = "[INFO]: Some Extra files or directories were detected. Examine the output log for details."
            0x04 = "[WARN]: Some Mismatched files or directories were detected. Examine the output log. Some housekeeping may be needed."
            0x08 = "[ERROR]: Some files or directories could not be copied (copy errors occurred and the retry limit was exceeded). Check these errors further."
            0x10 = "[ERROR]: Usage error or an error due to insufficient access privileges on the source or destination directories."
        }

        if( $returnCodeMessage.ContainsKey( $ProcessExitCode ) ) {
            $Message = $returnCodeMessage[$ProcessExitCode]
            Write-Host "[ROBOCOPY] " -f Blue -NoNewLine
            Write-Host "$Message" -f Gray

        }
        else {
            for( $flag = 1; $flag -le 0x10; $flag *= 2 ) {
                if( $ProcessExitCode -band $flag ) {
                    $returnCodeMessage[$flag]
                    $Message = $returnCodeMessage[$flag]
                    Write-Host "[ROBOCOPY] " -f Blue -NoNewLine
                    Write-Host "$Message" -f Gray
                }
            }
        }

        if($BackupMode){
            Write-Host '[ROBOCOPY] ' -f Blue -NoNewLine
            Write-Host "Disabling Privilege SeRestorePrivilege" -f Yellow                  
            [void][TokenManipulator]::RemovePrivilege("SeBackupPrivilege")
            Write-Host '[ROBOCOPY] ' -f Blue -NoNewLine
            Write-Host "Disabling Privilege SeRestorePrivilege" -f Yellow                  
            [void][TokenManipulator]::RemovePrivilege("SeRestorePrivilege")
        }

    }catch {
        Show-ExceptionDetails($_) -ShowStack
    }
}


function Compare-Directories {

    <#
      .SYNOPSIS
     
      .DESCRIPTION
     
      .EXAMPLE

    #>  

    [CmdletBinding(SupportsShouldProcess)]
    param(
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
        [String]$Left,
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Container) ){
                throw "The Path argument must be a Directory. Files paths are not allowed."
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=1)]
        [String]$Right
        
    )

    # throw errors on undefined variables
    Set-StrictMode -Version 1

    # stop immediately on error
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    # init counters
    $Items = $MissingRight = $MissingLeft = $Contentdiff = 0

    # make sure the given parameters are valid paths
    $left  = Resolve-Path $left
    $right = Resolve-Path $right

    # make sure the given parameters are directories
    if (-Not (Test-Path -Type Container $left))  { throw "not a container: $left"  }
    if (-Not (Test-Path -Type Container $right)) { throw "not a container: $right" }

    # Starting from $left as relative root, walk the tree and compare to $right.
    Push-Location $left

    try {
        Get-ChildItem -Recurse | Resolve-Path -Relative | ForEach-Object {
            $rel = $_
            
            $Items++
            
            # make sure counterpart exists on the other side
            if (-not (Test-Path $right\$rel)) {
                Write-Host "  -->  " -f DarkGreen -NoNewLine
                Write-Host "missing from right: $rel" -f White
                $MissingRight++
                return
                }
        
            # compare contents for files (directories just have to exist)
            if (Test-Path -Type Leaf $rel) {
                if ( Compare-Object (Get-Content $left\$rel) (Get-Content $right\$rel) ) {
                    Write-Host "  <" -f Magenta -NoNewLine
                    Write-Host "!" -f DarkRed -NoNewLine
                    Write-Host ">  " -f Magenta -NoNewLine
                    Write-Host "content differs   : $rel" -f White
                    $ContentDiff++
                    }
                }
            }
        }catch {
        Show-ExceptionDetails($_)
    }
    finally {
        Pop-Location
        }

    # Check items in $right for counterparts in $left.
    # Something missing from $left of course won't be found when walking $left.
    # Don't need to check content again here.

    Push-Location $right

    try {
        Get-ChildItem -Recurse | Resolve-Path -Relative | ForEach-Object {
            $rel = $_
            
            if (-not (Test-Path $left\$rel)) {
                Write-Host "  <--  " -f DarkMagenta -NoNewLine
                Write-Host "missing from left : $rel" -f White
                $MissingLeft++
                return
                }
            }
        }catch {
        Show-ExceptionDetails($_)
    }
    finally {
        Pop-Location
        }

    Write-Verbose "$Items items, $ContentDiff differed, $MissingLeft missing from left, $MissingRight from right"
}


function Get-DirectoryTree { 
    [CmdletBinding(SupportsShouldProcess)]
    param(
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
        [Parameter(Mandatory=$false)]
        [String]$Exclude
        
    )
    $Tree = [System.Collections.ArrayList]::new()   
    $Path=(Resolve-Path $Path).Path
    if ($Path.Chars($Path.Length - 1) -ne '\'){
        $Path = ($Path + '\')
    }

    $obj = [PSCustomObject]@{
        Path = $Path
        Relative = ''
    }
    $null=$Tree.Add($obj)    

    $BackupErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    try{
        If( $PSBoundParameters.ContainsKey('Exclude') -eq $True ){

            $DirList = Get-ChildItem $Path -Recurse -ErrorAction Ignore -Directory | where Fullname -notmatch "$Exclude"
            if($DirList -eq $Null){
                return $null
            }

            $DirList = $DirList | sort -Descending -unique
                
        }else{
            $DirList = (Get-ChildItem $Path -Recurse -Force -ErrorAction Ignore -Directory)
            if($DirList -eq $Null){
                return $Tree
            }
            $DirList = $DirList.Fullname | sort -Descending -unique
        }
        $len = $DirList.Length
        
        $DirList.ForEach({
            $fn = $_
            $rel = $fn.SubString($len, $fn.Length-$len)
            $obj = [PSCustomObject]@{
                Path = $fn
                Relative = $rel
            }
            $null=$Tree.Add($obj)
        })
        return $Tree
    }catch {
        Write-Host "[Get-DirectoryTree] " -n -f DarkRed
        Write-Host "Not found" -f DarkYellow
    }

    $ErrorActionPreference = $BackupErrorActionPreference
} 



function Remove-DirectoryTree
{ 

    <#
      .SYNOPSIS
     
      .DESCRIPTION
     
      .EXAMPLE

    #>  
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Container) ){
                throw "The Path argument must be a Directory. Files paths are not allowed."
            }
            return $true 
        })]        
        [String]$Path,
        [Parameter(Mandatory=$false)]
        [switch]$Force,
        [Parameter(Mandatory=$false)]
        [switch]$Test     
    )
    $Path=(Resolve-Path $Path).Path
    if ($Path.Chars($Path.Length - 1) -ne '\'){
        $Path = ($Path + '\')
    }    
    if($Force -eq $False){
        # Locate a HIDDEN subdirectory named .git . This means it's a GIT REpo, so ask for confirmation
        $GitDir = (gci -Path $Path -Directory  -Attributes Hidden | where Name -eq '.git')
        if($GitDir -ne $Null){ write-host "Warning: GIT REPO!" -f Red -b DarkYellow -NoNewLine ; $a=Read-Host -Prompt "$Path is a GIT repo! Are you sure (y/N)?" ; if($a -notmatch "y") {return;}  }

        $ExcludedPaths = (Get-ChildItem -Path 'C:\' -Depth 1 -Directory  -ErrorAction Ignore  )
        if($ExcludedPaths){
            $ExcludedNames = $ExcludedPaths.Fullname
            if( $ExcludedNames.Contains($Path) -eq $True ){
                write-host "WARNING" -f Red -b DarkGray -NoNewLine ; $a=Read-Host -Prompt "$Path is a HIGH LEVEL DIRECTORY! Are you sure (y/N)?" ; if($a -notmatch "y") {return;}
            }  
        }
         
    }

    $NumDeleted=0
    $NumErrors=0
    $NumOperations=0
    $erroroccured=$false
  
    $DirToRemove = Get-DirectoryTree $Path
    $DirToRemoveCount = $DirToRemove.Count
    Write-Host "[rmd] " -f DarkRed -NoNewLine
    Write-Host "Get Directory Tree . $DirToRemoveCount Branches to delete"  
    $DirToRemove.ForEach({
        $path = $_.Path
        $NumOperations++
        try{
            if( ($PSBoundParameters.ContainsKey('WhatIf') -eq $True) -Or ($PSBoundParameters.ContainsKey('Test') -eq $True)) {
                Write-Host "[WOULD delete] " -f Blue -n
                Write-Host "$path"    
                $NumDeleted++                
            }else{
                Remove-Item -Path "$path" -Recurse -Force -ErrorAction Ignore    
                $NumDeleted++
            }


        }catch{
         $NumDeleted++  
        }
    })

    Write-Host "=====================================================" -f DarkRed
    Write-Host "[rmd] " -f DarkRed -n
    Write-Host "Folders deleted $NumDeleted. Errors $NumErrors"

} 

function Directory-AutoUpdateProgress {   # NOEXPORT
    $Len = $Global:ServiceName.Length

    $Diff = 50 - $Len
    For($i = 0 ; $i -lt $Diff ; $i++){ [string]$Global:Channel = "$Global:Channel" + "." ;}
    $Global:ProgressMessage = "$Global:Channel... ( $Global:StepNumber on $Global:TotalSteps)"
    Write-Progress -Activity $Global:ProgressTitle -Status $Global:ProgressMessage -PercentComplete (($Global:StepNumber / $Global:TotalSteps) * 100)

}

function Remove-DirectoryBinaries
{ 

    <#
      .SYNOPSIS
     
      .DESCRIPTION
     
      .EXAMPLE

    #>  
    [CmdletBinding(SupportsShouldProcess)]
    param(
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
        [String]$Path
        
    )
    Write-Host "[BIN DELETE] " -f Blue -NoNewLine
    Write-Host "$Path" -f Gray
    $numFolders=0
    $erroroccured=$false
    pushd $Path
    
    [array]$List = (dir .\* -include ('*.obj', '*.exe', '*.dll', '*.pdb') -recurse) 
    if($List -eq $Null){
        Write-Host "[BIN DELETE] " -f Blue -NoNewLine
        Write-Host "Nothing to delete..." -f Gray
        return
    }
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $Global:ProgressTitle = 'BIN CLEANUP'
    $Global:StepNumber = 0
    $Global:TotalSteps = $List.Count
    $Global:ErrorList = [System.Collections.ArrayList]::new()
    $Global:ErrorCount = 0
    $List | % { 
        $FilesToDelete=$_;
        try{
            $Global:Channel = $FilesToDelete
            Remove-Item -Path $FilesToDelete -force -ErrorAction Stop    
            $Global:StepNumber++    
        }catch{
             $Global:ErrorCount++
        }
        Directory-AutoUpdateProgress
        
       
    }

    [int]$elapsedSeconds = $stopwatch.Elapsed.Seconds
    $stopwatch.Stop()
    Write-Host "[BIN DELETE] " -f Blue -NoNewLine
    Write-Host "COMPLETED IN $elapsedSeconds seconds" -f Gray
    Write-Host "[BIN DELETE] " -f Blue -NoNewLine
    Write-Host "Deleted $Global:StepNumber files" -f DarkGreen    
    Write-Host "[BIN DELETE] " -f Blue -NoNewLine
    Write-Host "encountered $Global:ErrorCount errors" -f DarkRed
    popd 
} 





function Get-DirectoryItem
{
    [CmdletBinding(SupportsShouldProcess)]
    param(
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
        [String]$Path
        
    )
  if ( $ParamSetName -eq "Path" ) {

    if ( Test-Path -Path $item -PathType Container ) {
      $item = Get-Item -Path $item -Force
    }
  }
  elseif ( $ParamSetName -eq "LiteralPath" ) {
    if ( Test-Path -LiteralPath $item -PathType Container ) {
      $item = Get-Item -LiteralPath $item -Force
    }
  }

  if ( $item -and ($item -is [System.IO.DirectoryInfo]) ) {
    return $item
  }
  return $null
}


function New-DirectoryTree
{
    [CmdletBinding(SupportsShouldProcess)]
    param(
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
        [String]$Root,
        [ValidateScript({
            if(($_ -lt 1) -Or ($_ -gt 12)){
                throw "User-defined directory levels must have a value between 1 and 12"
            }
            
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=1)]
        [int]$Level
        
    )

   
    $Path=(Resolve-Path $Root).Path
    if ($Path.Chars($Path.Length - 1) -ne '\'){
        $Path = ($Path + '\')
    }       
    $PathList = [System.Collections.ArrayList]::new()
    for($i = 0 ; $i -lt 60 ; $i++){
        [string]$Buffer = (New-Guid).Guid
        $Buffer = $Buffer -replace '-', '\'
        $Buffer += '\'
        $NewPath = $Path
        for($x = 0 ; $x -lt 2 ; $x++){
            [string]$NewPath += $Buffer
            $null = $PathList.Add($NewPath)
        }
        $c = $PathList.Count
        Write-Host "[DirectorySize] " -f Blue -NoNewLine
        
    }

    $PathList.ForEach({ $p = $_ ;  $p;$null = New-Item -Path $p -ItemType Directory  -Force; })

}



function Get-DirectorySize {
<#
    .SYNOPSIS

    Get-DirectoryInfo
    Returns the size of folders in MB and GB.

    .DESCRIPTION

    This function will get the folder size in MB and GB of folders found in the basePath parameter. 
    The basePath parameter defaults to C:\Users. You can also specify a specific folder name via the folderName parameter.
[ValidateNotNullOrEmpty()]
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
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
        [Parameter(Mandatory=$false,Position=1)]
        [String]$Excluded,
        [Parameter(Mandatory=$false)]
        [switch]$Recurse,
        [Parameter(Mandatory=$false)]
        [switch]$Details        
    )


     if ($PSBoundParameters.ContainsKey('Excluded')) {
        $allFolders = Get-ChildItem -Path $Path -Recurse:$Recurse -Directory -Force  | where FullName -NotMatch $Excluded
    }else{
        $allFolders = Get-ChildItem -Path $Path -Recurse:$Recurse -Directory -Force 
    }
    


    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    #Create array to store folder objects found with size info.
    [System.Collections.ArrayList]$folderList = @()
    $i = 1
    $TotalBytes = 0
    $TotalMb = 0
    $TotalGb = 0
    #Go through each folder in the base path.
    ForEach ($folder in $allFolders) {
        Write-Progress -Activity "Calculating size $($folder.name) ..." -Status "subfolder $i of $($allFolders.Count)" -PercentComplete (($i / $allFolders.Count) * 100)  
        $i++
        #Clear out the variables used in the loop.
        $fullPath = $null        
        $folderObject = $null
        $folderSize = $null
        $folderSizeInMB = $null
        $folderSizeInGB = $null
        $folderBaseName = $null

        #Store the full path to the folder and its name in separate variables
        $fullPath = $folder.FullName
        $folderBaseName = $folder.BaseName     

        Write-Verbose "Working with [$fullPath]..."            

        #Get folder info / sizes
        $folderSize = Get-Childitem -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property length -Minimum -Maximum -Sum -Average -ErrorAction SilentlyContinue       
            
        #We use the string format operator here to show only 2 decimals, and do some PS Math.

        $TotalBytes += $folderSize.Sum
        $TotalMb +=  ($folderSize.Sum / 1MB)
        $TotalGb +=  ($folderSize.Sum / 1GB)

        $folderSizeInMB = "{0} MB" -f ($folderSize.Sum / 1MB)
        $folderSizeInGB = "{0} GB" -f ($folderSize.Sum / 1GB)
        
        #Here we create a custom object that we'll add to the array
        $folderObject = [PSCustomObject]@{
                'Bytes'         = $folderSize.Sum
                'FolderName'    = $folderBaseName
                'FolderPath'    = $fullPath
                'Size(MB)'      = $folderSizeInMB
                'Size(GB)'      = $folderSizeInGB

        }                        
       
        #Add the object to the array
        $folderList.Add($folderObject) | Out-Null

    }


    [int]$elapsedSeconds = $stopwatch.Elapsed.Seconds
    $stopwatch.Stop()

    Write-Host "[DirectorySize] " -f Blue -NoNewLine
    Write-Host "COMPLETED IN $elapsedSeconds seconds" -f Gray

    $TotalSizeInBytesStr = "{0:n2} Bytes" -f $TotalBytes
    $TotalFolderSizeInMB = "{0:n2} MB" -f $TotalMb 
    $TotalFolderSizeInGB = "{0:n2} GB" -f $TotalGb
        
    Write-Host "[DirectorySize] " -f Blue -NoNewLine
    Write-Host "$TotalSizeInBytesStr" -f Gray
    Write-Host "[DirectorySize] " -f Blue -NoNewLine
    Write-Host "$TotalFolderSizeInMB" -f Gray
    Write-Host "[DirectorySize] " -f Blue -NoNewLine
    Write-Host "$TotalFolderSizeInGB" -f Gray    

    if($Details){
        return $folderList | Sort-Object -Property 'Bytes' -Descending 
    }
}







# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUyghCzawyo8luyKlTPh/ZzL37
# z1+gggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUSyaVYF103ApqJE3de3Vu
# ZXIC/lkwDQYJKoZIhvcNAQEBBQAEggEAhbVRVEVRlou03GIxJe4XqaMRX+XyIkan
# +KeOFWKNmeyI9MGRTX1ht3jM4PHG5yHS4lcrlB7hp9rS0/9QmE9lk7kFseIwIrYE
# rN991HcKIxPxRJd6g99lVukg+XcLJvEJikgdAo2y7ewjmqWXYubftVAkS9DirzQz
# s4uFBZSzb0UY4+0zq1Mht0enMv9R/FkfgIs8TItiok3kvrRVyarBLr/+AOzHM1+e
# TAgAALXHyPap1GeGEaq1LgHkHaY+8FyDg2XeirSXlPTkYkueXuYuKPqfvwse4FZw
# ny2DkBycOnqKqTDFSZcaaCEKdV2036lAgQnPXX5459gGKBoithmfCQ==
# SIG # End signature block
