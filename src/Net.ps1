<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

<#
EXAMPLE: 
$Hosts = @{}
Resolve-IPAddress 'security.ubuntu.com' -HostEntries $Hosts
Resolve-IPAddress 'archive.ubuntu.com' -HostEntries $Hosts

New-HostsFileFromHashTable  -Path "$pwd\h.txt" -HostEntries $Hosts

#>


function Resolve-IPAddress{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Hostname,
        [Parameter(Mandatory=$false)]
        [Hashtable]$HostEntries
    ) 

    Write-verbose "[resolving] $Hostname... "
    $Result = (Test-Connection -ResolveDestination -IPv4 -TargetName "$Hostname" -Count 1 -EA Ignore)
    
    if( $Result.Status -eq 'Success' ){
        $ip   = $Result.DisplayAddress
        $dest = $Result.Destination

        Write-verbose "[success]  $ip ($dest)" 

        if($PSBoundParameters.ContainsKey('HostEntries') -eq $True){
            Write-verbose "[HostEntries]  updating  HostEntries" 
            $HostEntries["$dest"] = "$ip"
        }
        return $ip
    }
    return ''
}

function New-HostsFileFromHashTable{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Path,
        [Parameter(Mandatory=$false)]
        [Hashtable]$HostEntries
    )   
    $Lines = [System.Collections.ArrayList]::new()
    $HostEntries.GetEnumerator() | ForEach-Object {
        $h = $($_.Key)
        $ip = $($_.Value)
        $entry = "{0}\t{1}" -f $h, $ip
        $Lines.Add($entry)
    }

    $HostsFilePath = "$pwd\HOSTS"
    Set-Content -Path $Path -Value $Lines

    write-host "$Path"
}
