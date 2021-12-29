<#̷#̷\
#̷\ 
#̷\   ⼕ㄚ乃㠪尺⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\    
#̷\   𝘗𝘰𝘸𝘦𝘳𝘴𝘩𝘦𝘭𝘭 𝘚𝘤𝘳𝘪𝘱𝘵 (𝘤) 𝘣𝘺 <𝘮𝘰𝘤.𝘥𝘶𝘰𝘭𝘤𝘪@𝘳𝘰𝘵𝘴𝘢𝘤𝘳𝘦𝘣𝘺𝘤>
#̷\ 
#̷##>




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
    $Res
    if($EncodeB64){
        $command = Get-Content -Path $ScriptPath -Raw
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        $action = New-ScheduledTaskAction -Execute "$PWSHEXE" -Argument "-ep Bypass -nop -W Hidden -NonI -EncodedCommand `"$encodedCommand`""
        $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
        $Res=Register-ScheduledTask $Id -InputObject $task
    }else{
        $action = New-ScheduledTaskAction -Execute "$PWSHEXE" -Argument "-ep Bypass -nop -W Hidden -NonI -File `"$ScriptPath`""
        $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
        $Res=Register-ScheduledTask $Id -InputObject $task
    }
    return $Res
}