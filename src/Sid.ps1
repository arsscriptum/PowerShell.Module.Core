<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

##===----------------------------------------------------------------------===
##  Account.ps1 - PowerShell script for account  data
##===----------------------------------------------------------------------===
 


function Convert-SIDtoName([String[]] $SIDs, [bool] $OnErrorReturnSID) {
    foreach ($sid in $SIDs) {
        try {
            $objSID = New-Object System.Security.Principal.SecurityIdentifier($sid) 
            $objUser = $objSID.Translate([System.Security.Principal.NTAccount]) 
            $objUser.Value
        } catch { if ($OnErrorReturnSID) { $sid } else { "" } }
    }
}

function Get-SIDUSerTable {
    [CmdletBinding(SupportsShouldProcess)]
    param ()  
    $WmicExe = (get-command wmic).Source  
    [array]$UsersSIDs=&"$WmicExe" "useraccount" "get" "name,sid"
    $UsersSIDsLen = $UsersSIDs.Length
    $SidIndex = $UsersSIDs[0].IndexOf('SID')
    $UserTable = [System.Collections.ArrayList]::new()
    For($i = 1 ; $i -lt $UsersSIDsLen ; $i++){
        $Len = $UsersSIDs[$i].Length
        if($Len -eq 0) { continue }
        $username = $UsersSIDs[$i].SubString(0,$SidIndex)
        $username = $username.trim()
        $sid = $UsersSIDs[$i].SubString($SidIndex)
        $res = [PSCustomObject]@{
                Username            = $username
                SID                 = $sid
        }
        $UserTable.Add($res)
    }
    return $UserTable
}

function Get-SIDValueForUSer {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$Username
    )
    $WmicExe = (get-command wmic).Source  
    [array]$UsersSIDs=&"$WmicExe" "useraccount" "get" "name,sid"
    $UsersSIDsLen = $UsersSIDs.Length
    $SidIndex = $UsersSIDs[0].IndexOf('SID')
    
    For($i = 1 ; $i -lt $UsersSIDsLen ; $i++){
        $Len = $UsersSIDs[$i].Length
        if($Len -eq 0) { continue }
        $usr = $UsersSIDs[$i].SubString(0,$SidIndex)
        $usr = $usr.trim()
        $sid = $UsersSIDs[$i].SubString($SidIndex)
        $sid = $sid.trim()
        $res = [PSCustomObject]@{
                Username            = $usr
                SID                 = $sid
        }
        if($Username -eq $usr){
            return $res
        }
    }
   
    return $null
}

function Get-USerSID
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$Username
    )
    
    try {
        $sid = Get-SIDValueForUSer $Username
        return $sid
    }
    catch {
        Write-Host '[Get-USerSID] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}

function Get-UserNtAccount
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$Username
    )
    
    try {
        $sid = (Get-USerSID $Username).SID
        $value = (Convert-SIDtoName $sid)
        $obj = $(new-object security.principal.ntaccount "$value")
        [System.Security.Principal.IdentityReference]$Principal = $(new-object security.principal.ntaccount "$value")
        return $Principal
       
    }
    catch {
        Write-Host '[Get-USerSID] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}