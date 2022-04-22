<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

function Get-WritableModulePath{

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

function Get-DefaultModulePath{
    $RegistryPath = "$ENV:OrganizationHKCU\powershell"
    Get-RegistryValue $RegistryPath "DefaultModulePath"
}

function Get-ModulePath{
    $VarModPath=$env:PSModulePath
    $Paths=$VarModPath.Split(';').ToLower()
    $WritablePaths=(Get-WritableModulePath).Path.ToLower()
    $Modules = [System.Collections.ArrayList]::new()
    ForEach($dir in $Paths){
        if(-not(Test-Path $dir)){ continue;}
        $Childrens = (gci $dir -Directory)
        $Mod = [PSCustomObject]@{
                Path            = $dir
                Writeable        = $WritablePaths.Contains($dir)
                Childrens       = $Childrens.Count
            }
        $Null = $Modules.Add($Mod)
    }
    return $Modules
}


function Select-FunctionName {        
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true, Position=0)]
        [String]$FnName
    )
    try{

        $WspIndex=$FnName.IndexOf(' ') # get the index of the first whitespace
        $FnLen=$FnName.Length        # take the length
        $WspIndex++
        $RealName = $FnName.SubString($WspIndex, $FnLen - $WspIndex)
        #Trim() method to remove all spaces before and after a string from the output
        $RealName = $RealName.trim()
        $FnName = $RealName
        $WspIndex=$FnName.IndexOf(' ')  ; # get the index of the second whitespace
        $BrkIndex=$FnName.IndexOf('{')  ; # get the index of the {
        $OpnIndex=$FnName.IndexOf('(')  ; # get the index of the (
        $EolIndex=$FnName.Length  ;  # get the index of the EOL
        $IndexFnEnd = 0
        if($EolIndex -ne -1){ Write-Verbose 'Function Ends with EOL' ;   Write-Verbose "$EolIndex" ;if(($EolIndex -le $IndexFnEnd) -Or ($IndexFnEnd -eq 0)) { $IndexFnEnd = $EolIndex } }
        if($WspIndex -ne -1){ Write-Verbose 'Function Ends with Whitespace' ; Write-Verbose "$WspIndex" ;  if(($WspIndex -le $IndexFnEnd) -Or ($IndexFnEnd -eq 0)) { $IndexFnEnd = $WspIndex } }
        if($BrkIndex -ne -1){ Write-Verbose 'Function Ends with Bracket ' ; Write-Verbose "$BrkIndex" ;; if(($BrkIndex -le $IndexFnEnd) -Or ($IndexFnEnd -eq 0)) { $IndexFnEnd = $BrkIndex } }
        if($OpnIndex -ne -1){ Write-Verbose 'Function Ends with Open ('; Write-Verbose "$OpnIndex" ; ;if(($OpnIndex -le $IndexFnEnd) -Or ($IndexFnEnd -eq 0)) { $IndexFnEnd = $OpnIndex } }
        $StrFunctionName = $FnName.SubString(0, $IndexFnEnd)
        $DebugStr = '"' + $StrFunctionName + '"'
        Write-Verbose "Function Returns $DebugStr" 
        
        return $StrFunctionName
    } 
    catch [Exception] { 
        Write-Host -ForegroundColor DarkRed "[ERROR]" $_.Exception.Message.Trim()
    }

    
}



function Get-FunctionList {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path,
        [switch]$All
    )

    $FunctionPattern = "function\s\w+-\w+"
    $IsFile = Test-Path -PathType Leaf -Path $Path
    $IsDirectory = Test-Path -PathType Container -Path $Path
    $TotalFnList = [System.Collections.ArrayList]::new()
    if($IsDirectory){
         $StrList = ( Get-ChildItem -Path $Path -Filter '*.ps1' | Select-String -Pattern $FunctionPattern )  # This will get a list of all the lines starting with 'function' followed by a space, then a word, then a '-' and a word. 
    }else{
         $StrList = ( Get-Content -Path $Path | Select-String -Pattern $FunctionPattern ) 
    }
   
    ForEach ( $fn in $StrList){
         $FnName=$fn.Line.trim()        # get the Line key/value from the select-string object
         $NoExport=$FnName.IndexOf('NOEXPORT');
         if(($All -eq $false) -And ($NoExport -ne -1)){ Write-Verbose "NOEXPORT: skipping $FnName" ; continue ; }
         if($IsDirectory){
            $FnPath = $fn.Path
            $FnBase = (Get-Item -Path $Fn.Path).Basename 
         }else{
            $FnPath = (Get-Item -Path $Path).Fullname
            $FnBase = (Get-Item -Path $Path).Basename 
         }

        $StrFunctionName = Select-FunctionName $FnName
        $FunctionInfoObject = [PSCustomObject]@{
            Name = $StrFunctionName
            Base = $FnBase
            Path = $FnPath
            Alias= ''
        }
        $null=$TotalFnList.Add($FunctionInfoObject)
    }
   return $TotalFnList | Sort-Object -Property Base | Select *
}

function Get-AssembliesDecl {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path
    )

    $RequiredAssemblies = "# !NOTE! --- The following functions declaration was automatically generated by the build script. ---`n`t"
    $RequiredAssemblies += 'RequiredAssemblies = @(' + ""
    $CurrentBase = ""
    $Dlls = (gci -Path $Path -File -Filter '*.dll')
    if($Dlls -EQ $null) { Write-Verbose "No Dlls in $Path" ; $RequiredAssemblies += ')' ; return $RequiredAssemblies ; }
    $AssemblyFiles = (gci -Path $Path -File -Filter '*.dll').Fullname

    $NumFunction = $AssemblyFiles.Length
    $Index = 1
    ForEach($assembly in $AssemblyFiles){
        $Entry =  resolve-path $assembly -Relative
      
        if(($Entry -eq $null) -Or ($Entry -eq '')) { continue ; }

        $RequiredAssemblies += "`n`t`t" + '"' + $Entry + '"'
        $RequiredAssemblies += ','
    }
    $RequiredAssemblies = $RequiredAssemblies -replace “.$”
    $RequiredAssemblies += ')'
    return $RequiredAssemblies
}


function Get-ExportedFunctionsDecl {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path
    )

    $FunctionDeclaration = "# !NOTE! --- The following functions declaration was automatically generated by the build script. ---`n`t"
    $FunctionDeclaration += 'FunctionsToExport = @(' + ""
    $CurrentBase = ""
    $FunctionList = Get-FunctionList $Path

    $NumFunction = $FunctionList.Length
    $Index = 1
    ForEach($func in $FunctionList){
        $Base = $func.Base
        $Name = $func.Name 
        if(($Name -eq $null) -Or ($Name -eq '')) { continue ; }
       
        if($CurrentBase -ne $Base){
            $StrComment = "`n`n`t`t# --- Exported Functions from $Base.ps1 ---"
            $CurrentBase = $Base
            $FunctionDeclaration += $StrComment 
        }

        $FunctionDeclaration += "`n`t`t" + '"' + $Name + '"'
        $FunctionDeclaration += ','
        $Index++
    }
    $FunctionDeclaration = $FunctionDeclaration -replace “.$”
    $FunctionDeclaration += ')'
    return $FunctionDeclaration
}


function Get-ExportedFilesDecl {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path
    )

    $FilesDeclaration = "# !NOTE! --- The following files declaration was automatically generated by the build script. ---`n`t# List of all files packaged with this module`n`n`t"
    $FilesDeclaration += 'FileList = @('
    $CurrentBase = ""
    $FilesList = (Get-FunctionList  $Path).Path | sort -unique
    $NumFiles = $FilesList.Length
    $Index = 1
    $DirName = (Get-Item $Path).Name
    ForEach($file in $FilesList){
        $At = $file.IndexOf("$DirName")
        $SubPath = $file.SubString($At, $file.Length - $At)
        $FilesDeclaration += "`n`t`t" + '"' + $SubPath + '"'
        if($Index -lt $NumFiles){
            $FilesDeclaration += ','
        }
        $Index++
    }

    $FilesDeclaration += ')'

    return $FilesDeclaration

}

function Select-AliasName {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true, Position=0)]
        [String]$String
    )
    try{
        $Begin = $String.IndexOf('-Name',[System.StringComparison]::CurrentCultureIgnoreCase)
        $End = $String.IndexOf('-Value',[System.StringComparison]::CurrentCultureIgnoreCase)
        $AliasName = $String.SubString($Begin +6, $End-$Begin -7 )
        $AliasName = $AliasName.trim()
        return $AliasName
    } 
    catch [Exception] { 
        Write-Host -ForegroundColor Red "[ERROR]" $_.Exception.Message.Trim()
    }
}


function Get-AliasList {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path
    )
    if(-not(Test-Path -Path $Path)) {return $null}
    $IsFile = Test-Path -PathType Leaf -Path $Path
    $IsDirectory = Test-Path -PathType Container -Path $Path
    
    if($IsDirectory){
         $StrList = ( Get-ChildItem -Path $Path -Filter '*.ps1' | Select-String -Pattern "New-Alias\s-Name\s\w+\s-Value\s\w+" -Raw )  # This will get a list of all the lines starting with 'function' followed by a space, then a word, then a '-' and a word. 
    }else{
         $StrList = ( Get-Content -Path $Path | Select-String -Pattern "New-Alias\s-Name\s\w+\s-Value\s\w+" -Raw ) 
    }
   
    $AliasList = [System.Collections.ArrayList]::new()
    ForEach ( $a in $StrList){
        $AliasName=Select-AliasName $a        # get the Line key/value from the select-string object
        if(($AliasName -eq $null) -Or($AliasName -eq '')){ continue; }
        $CmdName=''
        $data=(get-alias $AliasName -ErrorAction ignore)
        if($data -ne $null){ $CmdName=($data | select ResolvedCommandName).ResolvedCommandName }
        $AliasInfoObject = [PSCustomObject]@{
            Name    = $AliasName
            Command = $CmdName
        }
        $null=$AliasList.Add($AliasInfoObject)
    }
   return $AliasList | Sort-Object -Property Name | Select *
}


function Get-ExportedAliassDecl {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path
    )
    if(!$Path.EndsWith("\")) {$Path+="\"}
    $AliasList = Get-AliasList $Path

    $AliasDeclaration = "# !NOTE! --- The following alias declaration was automatically generated by the build script. ---`n`t# List of all aliases packaged with this module`n`n`t"
    $AliasDeclaration += 'AliasesToExport = @('

    if($AliasList -ne $Null){
        $NumAlias = $AliasList.Length
        $Index = 1
        ForEach($alias in $AliasList){
            $Name = $alias.Name
            if(($Name -eq $null) -Or($Name -eq '')){ continue; }
            $AliasDeclaration += "`n`t`t" + '"' + $Name + '"'
            if($Index -lt $NumAlias){
                $AliasDeclaration += ','
            }
            $Index++
        }
    }
    $AliasDeclaration += ')'
    return $AliasDeclaration
}



function Approve-FunctionNames {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path
    )
    
    $Functions=(Get-FunctionList $Path).Name
    $OfficialVerbs = (Get-Verb).Verb
    $NumFuntions=0
    $NumErrors=0
  
    foreach($fn in $Functions){
         $i = $fn.IndexOf('-')
         $verb = $fn.SubString(0,$i)
         $ProperVerb = $OfficialVerbs.Contains($verb)
         if($ProperVerb -eq $true){
            $NumFuntions++
            Write-Host -f DarkGreen "[OK] " -NoNewline
            Write-Host "Function $fn has proper verb" -f DarkGray
         }else{
            $NumErrors++
            Write-Host -f DarkRed "[ERROR] " -NoNewline
            Write-Host "Function $fn has INCORRECT verb ($verb)" -f DarkGray
        }
    }
    if($NumErrors -eq 0){
        $NumFuntions++
        Write-Host -f DarkGreen "[OK] " -NoNewline
        Write-Host "No errors in function names. Path: $Path" -f Gray
    }else{
        Write-Host -f DarkRed "[ERROR] " -NoNewline
        Write-Host "Found $NumErrors errors. Path: $Path" -f Gray
    }
    return $NumErrors
}


function Invoke-ValidateDependencies{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.ArrayList]$FunctionList
    )
    $NumFuntions=0
    $NumErrors=0
  
    foreach($function in $FunctionList){
        $cmd=get-command -Name $function
        if($cmd -ne $null){
            $NumFuntions++
            Write-Host -f DarkGreen "[OK] " -NoNewline
            Write-Host "Function $function detected in scope" -f DarkGray
        }else{
            $NumErrors++
            Write-Host -f DarkRed "[ERROR] " -NoNewline
            Write-Host "Failed to find Function $function" -f DarkGray
        }
    }
    
    return ( $NumErrors -eq 0 )
}



function Install-ModuleToDirectory {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="Module name") ]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Installation Path (default to DefaultModulePath)") ]
        [string]$Path,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Online Module Repository") ]
        [string]$Repository,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Import after installation") ]
        [switch]$Import,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Force installation on existing directory") ]        
        [switch]$Force,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Open exlorer in the module path") ]        
        [switch]$OpenExplorer        

    )
 <#
    .Synopsis
        Similar to the ative Install-Module function, but install the module in a specified folder
    .Description
        Similar to the ative Install-Module function, but install the module in a specified folder
    .Parameter Name
        Specifies the names of modules to search for in the repository. A comma-separated list of module names is accepted. Wildcards are accepted.
    .Parameter Path
        Installation Path
    .Parameter Repository
        Use the Repository parameter to specify which repository to search for a module. Used when multiple repositories are registered. Accepts a comma-separated list of repositories. To register a repository, use Register-PSRepository. To display registered repositories, use Get-PSRepository.
    .Parameter Import
        Import or no
    .Parameter WhatIf
        Do or simulate
    .Example 
        $ModulePath = 'C:\Programs\Powershell\Modules'
        New-Item $ModulePath -ItemType 'Directory' -Force

        Foreach( $mod in $Modules ){
            Install-ModuleToDirectory $mod $ModulePath "PSGallery" $True
        }
#>
    [PSCustomObject]$Module = $null
    [version]$ModuleVersion = $null
    [string]$ModuleDescription= $null
    [datetime]$ModulePublishedDate= get-date
    $FatalError = $True
    try{
        $ReturnValue = $False
        $InstalledModule = Get-Module $Name
        if($InstalledModule -ne $Null){ $FatalError = $True ; throw "Module Already installed $Name"; $Mod ; }

        If( $PSBoundParameters.ContainsKey('Path') -eq $False ){
            Write-Verbose "Getting DefaultModulePath"
            $Path = Get-DefaultModulePath
            Write-Verbose "Using Default Module Path $Path"
        }

        if(-not(Test-Path -Path $Path -PathType Container)){ $FatalError = $True ; throw "Could not validate Path $Path" ;}
        $ModulePath = Join-Path $Path $Name
        if($Force){
            Remove-Item $ModulePath -Recurse -Force -ErrorAction Ignore | out-null 
            New-Item $ModulePath -Force -ErrorAction Ignore | out-null 
            Remove-Item $ModulePath -Recurse -Force -ErrorAction Ignore | out-null 
        }else{
            if(Test-Path -Path $ModulePath -PathType Container){ $FatalError = $True ;throw "Destination Path already exists : $ModulePath"; }
            New-Item $ModulePath -Force -ErrorAction Ignore | out-null 
            Remove-Item $ModulePath -Recurse -Force -ErrorAction Ignore | out-null 
        }
        If( $PSBoundParameters.ContainsKey('Repository') -eq $False ){
            Write-ChannelMessage "No repository specified, defaulting to PSGallery"
            $Repository='PSGallery'
        }
        Write-ChannelMessage "Searching for Module $Name in repository $Repository..."
        [PSCustomObject[]]$Found = Find-Module -Name $Name -Repository $Repository -ErrorAction Stop
        [PSCustomObject]$Module = $Found[0]
        [version]$ModuleVersion = $Module.Version
        [string]$ModuleDescription= $Module.Description
        [datetime]$ModulePublishedDate= $Module.PublishedDate

        Write-ChannelResult "ModuleVersion  `t$ModuleVersion"
        Write-ChannelResult "Description    `t$ModuleDescription"
        Write-ChannelResult "Published Date `t$ModulePublishedDate"
        $Exp = (Get-Command 'explorer.exe').Source
        If( $PSBoundParameters.ContainsKey('WhatIf') -eq $False ){
            Write-ChannelMessage "Saving in root path $Path. [$ModulePath]"
            $Module | Save-Module -Path $Path -Force -ErrorAction Stop | out-null 
            if($Import){
                Write-ChannelMessage "Importing Module from $ModulePath"
                # Import the module from the custom directory.
                Import-Module -FullyQualifiedName $ModulePath -ErrorAction Stop | out-null 
                $InstalledModule = Get-Module $Name
                if($InstalledModule -eq $Null){ throw "Module import failure for $Name"; }
            }
            if($OpenExplorer) { &"$Exp" $ModulePath }
        }else{
            Write-ChannelMessage "WHATIF : Terminating"
        }
        $ReturnValue = $True
    } catch {
        Show-ExceptionDetails($_)
        $ReturnValue = $False
        if($FatalError){
            return $ReturnValue    
        }
        
    }

    return $ReturnValue
}


function Import-CustomModule {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, HelpMessage="Full repository Url https or ssh") ]
        [String]$Name,
        [switch]$Force
    ) 
 <#
    .Synopsis
        Similar to the ative Import-Module function, but Import the module using shorter names
    .Description
        Similar to the ative Import-Module function, but Import the module using shorter names
    .Parameter Name
        Specifies the names of modules 

    .Example 
        Import-CustomModule CodeCastor.PowerShell.Core
        Import-CustomModule Core -c
#>

    pushd "$ENV:PSModDev"

    $AllMods = @(gci . -Directory).Name ; 
    ForEach($mod in $AllMods){
        if($mod -match $Name){
            Write-Host -n "Loading " -f DarkRed ;
            Write-Host "$mod" -f DarkYellow ;
            import-module $mod -Force:$Force -DisableNameChecking  -SkipEditionCheck -Global;
            $ModData = Get-Module | where Name -Match $Name -ErrorAction Ignore
            If($ModData -eq $Null){
                Write-Host " NOT LOADED" -f DarkRed ;
                return
            }
            $RootModule = $ModData.RootModule
            $Author = $ModData.Author
            $Version = $ModData.Version
            $Copyright = $ModData.Copyright
            Write-Host "✅ $RootModule $Version loaded."
            Write-Host "✅ $Copyright"            
        }
    }

}


# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU25TC0MdOue6lW6kDwZe2L2Ja
# im6gggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU2tOGjrn19iVY3wdsI/lt
# /6K3nPcwDQYJKoZIhvcNAQEBBQAEggEAB4J4lN7qV3gT2hswda6CuG4QK0X6+vI1
# UfjvaHQ/Itm0MnaMJbiemR30p4a5Hm7XRpvoc19oGs/WEb7B4CmvbHXX1CxmlCKo
# P/1R4Fp/mjBpiyK0YfaXezJywKc5HMGPYiH30kXyMPvEvxBQ3VtI55X8rdCd6T88
# PR8uOmWMd3roZmSCetLp6oWbEeVbNqle8RX0igKo+6qKBO4o7tOLcv8tTSTn3ezn
# 4DdPhHpYIzqlEB11Qta30Sq4jm2LYGYqqklDR6BXTVvP9nE1vp3h2CjA7xsnw85t
# XWd/+uE2Cv6Gm/s1qZDN4dPMG3CX/GSqBfHwkT3bK2j3XdVC7zDWrg==
# SIG # End signature block
