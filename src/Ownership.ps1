
<#
#ฬท๐   ๐๐ก๐ข ๐ข๐๐ก๐๐๐ฃ๐ค๐
#ฬท๐   ๐ตโโโโโ๐ดโโโโโ๐ผโโโโโ๐ชโโโโโ๐ทโโโโโ๐ธโโโโโ๐ญโโโโโ๐ชโโโโโ๐ฑโโโโโ๐ฑโโโโโ ๐ธโโโโโ๐จโโโโโ๐ทโโโโโ๐ฎโโโโโ๐ตโโโโโ๐นโโโโโ ๐งโโโโโ๐พโโโโโ ๐ฌโโโโโ๐บโโโโโ๐ฎโโโโโ๐ฑโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐บโโโโโ๐ฒโโโโโ๐ชโโโโโ๐ตโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐ณโโโโโ๐นโโโโโ๐ชโโโโโ.๐ถโโโโโ๐จโโโโโ@๐ฌโโโโโ๐ฒโโโโโ๐ฆโโโโโ๐ฎโโโโโ๐ฑโโโโโ.๐จโโโโโ๐ดโโโโโ๐ฒโโโโโ
#>



function Get-PrivStatus{

<#
    .SYNOPSIS
    Get the status of a Privilege for the user

    .DESCRIPTION
    Get the status of a Privilege for the user using whoami

    .PARAMETER Privilege
    The Privilege term to query

   
    .EXAMPLE 
       Get-PrivStatus -Privilege "SeSecurityPrivilege"



#>


    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Privilege
    )  

    try{
        $WAMEXE = (get-command whoami.exe).Source

        $Res = &"$WAMEXE" /priv | Select-String "$Privilege" -Raw
        $Status = $Res.substring($Res.length-10).Trim()

        return $Status  
    }
    catch{
         Show-ExceptionDetails $_
    }
}

function Set-Owner {

<#
    .SYNOPSIS
    Set-Ownership of a file / folder

    .DESCRIPTION
    Invoke [TokenMod]::AddPrivilege (privileges.ps1) to add the privileges then change the ownership

    .PARAMETER Path
    The search term to query

    .PARAMETER Principel
    $u = $(new-object security.principal.ntaccount "$env:computername\MyUSer")
    or
    Get-UserNtAccount MyUSer
    .EXAMPLE 
       Set-Owner -Path "c:\Tmp" -Principal $(new-object security.principal.ntaccount "$env:computername\MyUSer")



#>


    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [System.Security.Principal.IdentityReference]$Principal,
        [Parameter(Mandatory=$false)]
        [switch]$AddPrivileges
    )  

    Write-Verbose "ErrorActionPreference is $ErrorActionPreference"
    $errPref = $ErrorActionPreference
    $ErrorActionPreference= "silentlycontinue"
    $type = [TokenManipulator]
    $ErrorActionPreference = $errPref
    Write-Verbose "setting ErrorActionPreference to $errPref"
    Write-Verbose "Loading TokenManipulator"
    if($type -eq $null){
        throw "NO TYPE TokenManipulator registered"
        Write-Verbose "NO TYPE TokenManipulator registered"
    }

    if($AddPrivileges){
        $Privilege = "SeRestorePrivilege" ;  $Status = Get-PrivStatus $Privilege ; Write-Host "[$Privilege] " -f DarkRed -n ; Write-Host "$Status" -f DarkYellow  
        $Privilege = "SeBackupPrivilege" ;  $Status = Get-PrivStatus $Privilege ; Write-Host "[$Privilege] " -f DarkRed -n ; Write-Host "$Status" -f DarkYellow  
        $Privilege = "SeTakeOwnershipPrivilege" ;  $Status = Get-PrivStatus $Privilege ; Write-Host "[$Privilege] " -f DarkRed -n ; Write-Host "$Status" -f DarkYellow  
        Write-Verbose "AddPrivilege SeRestorePrivilege"
        [void][TokenManipulator]::AddPrivilege("SeRestorePrivilege")
        Write-Verbose "AddPrivilege SeBackupPrivilege"
        [void][TokenManipulator]::AddPrivilege("SeBackupPrivilege")
        Write-Verbose "AddPrivilege SeTakeOwnershipPrivilege"
        [void][TokenManipulator]::AddPrivilege("SeTakeOwnershipPrivilege")    

        $Privilege = "SeRestorePrivilege" ;  $Status = Get-PrivStatus $Privilege ; Write-Host "[$Privilege] " -f DarkRed -n ; Write-Host "$Status" -f DarkYellow  
        $Privilege = "SeBackupPrivilege" ;  $Status = Get-PrivStatus $Privilege ; Write-Host "[$Privilege] " -f DarkRed -n ; Write-Host "$Status" -f DarkYellow  
        $Privilege = "SeTakeOwnershipPrivilege" ;  $Status = Get-PrivStatus $Privilege ; Write-Host "[$Privilege] " -f DarkRed -n ; Write-Host "$Status" -f DarkYellow          
    }
    
    Write-Verbose "Get-Acl $Path"
    $acl = Get-Acl $Path

    Write-Verbose "SetOwner($Principal)"
    $acl.psbase.SetOwner($Principal)

    set-acl -Path $Path -AclObject $acl -passthru

    if($AddPrivileges){
        [void][TokenManipulator]::RemovePrivilege("SeRestorePrivilege")
        [void][TokenManipulator]::RemovePrivilege("SeBackupPrivilege")
        [void][TokenManipulator]::RemovePrivilege("SeTakeOwnershipPrivilege")    
    }

}




function Set-OwnerU {

<#
    .SYNOPSIS
    Set-Ownership of a file / folder

    .DESCRIPTION
    Invoke [TokenMod]::AddPrivilege (privileges.ps1) to add the privileges then change the ownership

    .PARAMETER Path
    The search term to query

    .PARAMETER Username

    .EXAMPLE 
       Set-Owner -Path "c:\Tmp" -Username $(new-object security.principal.ntaccount "$env:computername\MyUSer")



#>


    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [string]$Username
    )  

    try{
        [System.Security.Principal.IdentityReference]$Principal = Get-UserNtAccount $Username
        if($Principal -eq $NUll) { throw "CANNOT FIND Principal.IdentityReference for $Username" }
        Set-Owner -Path $Path -Principal $Principal
    }
    catch{
         Show-ExceptionDetails $_
    }
}
    

function Set-OwnerUByAdmin {


    [CmdletBinding()]
    Param
    (
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [string]$Username
    )  

    try{
        $EncodedScriptCode = "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"
        $ScriptCode = Convert-FromBase64CompressedScriptBlock $EncodedScriptCode
        $AddStr = 'Set-OwnerU -Path ' + $Path + ' -Username ' + $Username
        $ScriptCode += "`n`n"
        $ScriptCode += $AddStr
        $ScriptCode += "`n`nSleep 3"
        $TmpFile = (New-TemporaryFile).Fullname + '.ps1'
        Set-Content -Path $TmpFile -Value $ScriptCode
        Start-Process pwsh.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $TmpFile) -Verb RunAs
     
    }
    catch{
         Show-ExceptionDetails $_
    }
}
   