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


