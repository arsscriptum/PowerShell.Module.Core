<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Get-BackupFolder {

    $Path = ''
    $DateStr = get-date -f "MMdd-HHmm"
    $BackupRoot =  Get-RegistryValue "$ENV:OrganizationHKCU\terminal" "CurrentProjectPath"
    if( $BackupRoot -ne $null ) { 
        $Path = Join-Path $BackupRoot $DateStr 
    }elseif( $Env:SYSTEM_BACKUP_ROOT -ne $null )  { 
        $Path = Join-Path $Env:SYSTEM_BACKUP_ROOT $DateStr 
    }else{
        throw "CANNOT RETRIEVE BACKUP PATH"
    }

    $null=new-item -Path $Path -itemtype Directory -Force -ErrorAction ignore

    return $Path
}


function Backup-Profile {
    $p = Get-BackupFolder
    $Archive = Join-Path $p "Profile.zip"
    $compress = @{
        Path = "$Profile", "$HOME\.ssh", "$HOME\.bash_profile"
        CompressionLevel = "Fastest"
        DestinationPath = $Archive
    }
    Compress-Archive @compress
}
