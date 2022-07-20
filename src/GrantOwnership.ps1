
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


<#
    .SYNOPSIS
        Cmdlet to do simple management of Windows permissions.
             
    .DESCRIPTION
        Cmdlet to do simple management of Windows permissions for different object types:
    .PARAMETER Path
    .PARAMETER Recurse
    .PARAMETER ObjectType
        File    Directory/file
        reg     Registry key
        srv     Service
        shr     Network share
        wmi     WMI objec
    .EXAMPLE
        Grant-Ownership 'c:\MyTest'
        Grant-Ownership 'c:\MyTest' -Recurse
        Grant-Ownership 'HKCU\SOFTWARE\CodeCastor\Test' -ObjectType registry
    .Notes
        REGISTRY VALUE
        HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\TakeOwn\command
        pwsh.exe -noni -nol -nop -c "& { Start-Process -Verb RunAs -FilePath "pwsh.exe" -ArgumentList '-noni -nol -nop -c "& { C:\Scripts\powershell-sandbox\TakeOwn\TakeOwn.ps1 "%1" ; Sleep 5 ;}"' }"
 #>



function Get-SetAclExe{
    [CmdletBinding(SupportsShouldProcess)]
    param()

   try{
        $Cmd = Get-Command -Name 'SetACL.exe' -ErrorAction Ignore
        if($Cmd -eq $Null) { throw "Cannot find setacl.exe" }
        $SetACLExe = $Cmd.Source
        if(-not(Test-Path $SetACLExe)){ throw "cannot fin setacl executable. is it installed ?" }
        return $SetACLExe
    }catch{
        Show-ExceptionDetails $_
    }
    return $Null
}



function Test-IsAdministrator  {  # NOEXPORT
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

function Grant-Ownership{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path,
        [Parameter(Mandatory=$false)]
        [ValidateSet('file','reg','srv','shr','wmi')]
        [String]$ObjectType,        
        [Parameter(Mandatory=$false)]
        [switch]$Recurse,
		[Parameter(Mandatory=$false)]
        [switch]$Force
    )    
    try{

        if(-not(Test-IsAdministrator)){
            throw "Administrator privileges required"
        }
		if($Force -eq $False){
			$Advisory = "Are you sure you want to change the Acl/Dacl properties of $Path "
			if($Recurse){
				$Advisory += 'and subfolders '
			}
			$Advisory += ' (y/N)?'
			write-host "`t`t`t`t!!! CRITICAL OPERATION WARNING!!!`n" -f DarkRed  -NoNewLine ; $a=Read-Host -Prompt $Advisory ; if($a -notmatch "y") {return;}	
		}else{
			write-host "[i] Change the Acl/Dacl properties of $Path " -f DarkRed ; 
		}
				
        
        If( $PSBoundParameters.ContainsKey('ObjectType') -eq $True ){
            Write-ChannelMessage " ObjectType $ObjectType"
        }else{
            Write-ChannelMessage " ObjectType file"
            $ObjectType = 'file'
        }     

        if($ObjectType -eq 'file'){
            if(-not(Test-Path $Path)){
                throw "Invalid Path specified"
            }
        }
        $me=whoami
        $SetAclExe = (Get-Command SetACL.exe).source
     
        $ArgumentList = '-on "' + $Path + '" -ot ' + $ObjectType + ' -actn setowner -ownr "n:' + $me + '" -actn ace -ace "n:' + $me + ';p:full" -rec '
        <#
            no          No recursion.
            cont        Recurse, and process directories only.
            obj         Recurse, and process files only.
            cont_obj    Recurse, and process directories and files.
        #>
        if($Recurse){
            $ArgumentList += 'cont_obj'
        }else{
            $ArgumentList += 'no'
        }
        Write-ChannelMessage "$ObjectType : $Path. Recurse $Recurse"
        #$creds=Get-ElevatedCredential
        $process = Start-Process -FilePath $SetAclExe -ArgumentList $ArgumentList -Wait -NoNewWindow -Passthru
        $handle = $process.Handle # cache proc.Handle
        $null=$process.WaitForExit();
      
   
        # This will print out False/True depending on if the process has ended yet or not
        # Needs to be called for the command below to work correctly
        $null=$process.HasExited
        $ProcessExitCode = $process.ExitCode
        if ($ProcessExitCode -ne 0) {
            Write-ChannelResult " ERROR takeown exited with status code $ProcessExitCode" -Warning
            throw " ERROR takeown exited with status code $ProcessExitCode"
        }
        Write-ChannelResult " SUCCESS. Done"
    }
    catch{
        Write-Error $_
    }
    finally{
        Sleep 2
    }
}
