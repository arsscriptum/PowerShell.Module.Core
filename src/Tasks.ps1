<#
#ฬท๐   ๐๐ก๐ข ๐ข๐๐ก๐๐๐ฃ๐ค๐
#ฬท๐   ๐ตโโโโโ๐ดโโโโโ๐ผโโโโโ๐ชโโโโโ๐ทโโโโโ๐ธโโโโโ๐ญโโโโโ๐ชโโโโโ๐ฑโโโโโ๐ฑโโโโโ ๐ธโโโโโ๐จโโโโโ๐ทโโโโโ๐ฎโโโโโ๐ตโโโโโ๐นโโโโโ ๐งโโโโโ๐พโโโโโ ๐ฌโโโโโ๐บโโโโโ๐ฎโโโโโ๐ฑโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐บโโโโโ๐ฒโโโโโ๐ชโโโโโ๐ตโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐ณโโโโโ๐นโโโโโ๐ชโโโโโ.๐ถโโโโโ๐จโโโโโ@๐ฌโโโโโ๐ฒโโโโโ๐ฆโโโโโ๐ฎโโโโโ๐ฑโโโโโ.๐จโโโโโ๐ดโโโโโ๐ฒโโโโโ
#>




Function New-ScheduledTaskFolder{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$TaskPath
    )
    $BackupEA = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    Log-String "New-ScheduledTaskFolder called with path $TaskPath"


    $scheduleObject = New-Object -ComObject schedule.service
    $scheduleObject.connect()
    $rootFolder = $scheduleObject.GetFolder("\")
    Try 
    {
        $null = $scheduleObject.GetFolder($TaskPath)
    }
    Catch { 
        $null = $rootFolder.CreateFolder($TaskPath) 
        $ErrorActionPreference = $BackupEA
    }
    Finally { 
        $ErrorActionPreference = $BackupEA
    } 
}



function Install-SimpleTask {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Id,
        [Parameter(Mandatory=$true)]
        [datetime]$When,
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
                throw "The Path argument must be a File. Directory paths are not allowed."
            }
            return $true 
        })]
        [Parameter(Mandatory=$true)]
        [string]$ScriptPath,
        [Parameter(Mandatory=$false)]
        [string]$User,
        [Parameter(Mandatory=$false)]
        [switch]$EncodeB64
    )

    if ($PSBoundParameters.ContainsKey('User') -eq $False) {
        $User = whoami
    }

    $PWSHEXE = (Get-Command pwsh.exe).Source
    $me = whoami
    $trigger = New-ScheduledTaskTrigger -Once -At $When
    
    $settings = New-ScheduledTaskSettingsSet -Hidden -Priority 3
    $principal = New-ScheduledTaskPrincipal -UserID "$User"
    #$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    if($EncodeB64){
        $command = Get-Content -Path $ScriptPath -Raw
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        $action = New-ScheduledTaskAction -Execute "$PWSHEXE" -Argument "-ep Bypass -nop -W Hidden -NonI -EncodedCommand `"$encodedCommand`""
        $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
        $ResultingTask = Register-ScheduledTask $Id -InputObject $task


        $T_State = ($ResultingTask).State
        $T_Name = ($ResultingTask).TaskName

        Write-Host "[SCHEDULED TASK] " -f DarkYellow -n
        Write-Host "Name ==> $T_Name. State ==> $T_State" -DarkGreen
    }else{
        $action = New-ScheduledTaskAction -Execute "$PWSHEXE" -Argument "-ep Bypass -nop -W Hidden -NonI -File `"$ScriptPath`""
        $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
        $ResultingTask=Register-ScheduledTask $Id -InputObject $task


        $T_State = ($ResultingTask).State
        $T_Name = ($ResultingTask).TaskName

        Write-Host "[SCHEDULED TASK] " -f DarkYellow -n
        Write-Host "Name ==> $T_Name. State ==> $T_State" -DarkGreen
    }
}