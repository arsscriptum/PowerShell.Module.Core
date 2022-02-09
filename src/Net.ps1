<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell Core Module
  ╙──────────────────────────────────────────────────────────────────────────────────────
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


function Get-OnlineFileNoCache{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Url,
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$false)]
        [string]$ProxyAddress,
        [Parameter(Mandatory=$false)]
        [string]$ProxyUser,
        [Parameter(Mandatory=$false)]
        [string]$ProxyPassword,
        [Parameter(Mandatory=$false)]
        [string]$UserAgent=""
    )

    $ForceNoCache=$True

    $client = New-Object Net.WebClient
    if( $PSBoundParameters.ContainsKey('ProxyAddress') ){
        Write-Warning ('NetGetFileNoCache''s -ProxyAddress parameter is not tested.')
        $proxy = New-object System.Net.WebProxy "$ProxyAddress"
        $proxy.Credentials = New-Object System.Net.NetworkCredential ($ProxyUser, $ProxyPassword) 
        $client.proxy=$proxy
    }
    
    if($UserAgent -ne ""){
        $Client.Headers.Add("user-agent", "$UserAgent")     
    }else{
        $Client.Headers.Add("user-agent", "Mozilla/5.0 (iPhone; CPU iPhone OS 13_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1") 
    }

    $RequestUrl = "$Url"

    if ($ForceNoCache) {
        # doesn’t use the cache at all
        $client.CachePolicy = New-Object Net.Cache.RequestCachePolicy([Net.Cache.RequestCacheLevel]::NoCacheNoStore)

        $RandId=(new-guid).Guid
        $RandId=$RandId -replace "-"
        $RequestUrl = "$Url" + "?id=$RandId"
    }
    Write-Host "NetGetFileNoCache: Requesting $RequestUrl"
    $client.DownloadFile($RequestUrl,$Path)
}

function Get-OnlineStringNoCache{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Url,
       
        [Parameter(Mandatory=$false)]
        [string]$ProxyAddress,
        [Parameter(Mandatory=$false)]
        [string]$ProxyUser,
        [Parameter(Mandatory=$false)]
        [string]$ProxyPassword,
        [Parameter(Mandatory=$false)]
        [string]$UserAgent=""
    )

    $ForceNoCache=$True

    $client = New-Object Net.WebClient
    if( $PSBoundParameters.ContainsKey('ProxyAddress') ){
        Write-Warning ('NetGetStringNoCache''s -ProxyAddress parameter is not tested.')
        $proxy = New-object System.Net.WebProxy "$ProxyAddress"
        $proxy.Credentials = New-Object System.Net.NetworkCredential ($ProxyUser, $ProxyPassword) 
        $client.proxy=$proxy
    }
    
    if($UserAgent -ne ""){
        $Client.Headers.Add("user-agent", "$UserAgent")     
    }else{
        $Client.Headers.Add("user-agent", "Mozilla/5.0 (iPhone; CPU iPhone OS 13_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1") 
    }

    $RequestUrl = "$Url"

    if ($ForceNoCache) {
        # doesn’t use the cache at all
        $client.CachePolicy = New-Object Net.Cache.RequestCachePolicy([Net.Cache.RequestCacheLevel]::NoCacheNoStore)

        $RandId=(new-guid).Guid
        $RandId=$RandId -replace "-"
        $RequestUrl = "$Url" + "?id=$RandId"
    }
    Log-String "NetGetStringNoCache: Requesting $RequestUrl"
    $client.DownloadString($RequestUrl)
}