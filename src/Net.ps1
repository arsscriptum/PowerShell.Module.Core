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
        [Parameter(Mandatory=$false)]
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

	if( -not ($PSBoundParameters.ContainsKey('Path') )){
		$Path = (Get-Location).Path
		[Uri]$Val = $Url;
		$Name = $Val.Segments[$Val.Segments.Length-1]
		$Path = Join-Path $Path $Name
		Write-Warning ("NetGetFileNoCache using path $Path")
	}
    $ForceNoCache=$True

    $client = New-Object Net.WebClient
    if( $PSBoundParameters.ContainsKey('ProxyAddress') ){
        Write-Warning ("NetGetFileNoCache''s -ProxyAddress parameter is not tested.")
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


function Invoke-DownloadFileWithProgress{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]$Url,
        [Parameter(Mandatory=$True, Position=1)]
        [string]$DestinationPath    
    ) 
  try{
    new-item -path $DestinationPath -ItemType 'File' -Force | Out-Null
    remove-item -path $DestinationPath -Force | Out-Null

    $Script:ProgressTitle = 'STATE: DOWNLOAD'
    $uri = New-Object "System.Uri" "$Url"
    $request = [System.Net.HttpWebRequest]::Create($Url)
    $request.PreAuthenticate = $false
    $request.Method = 'GET'


    $request.Headers.Add('User-Agent','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Safari/537.36')
    $request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9'
    $request.KeepAlive = $true
    $request.Timeout = ($TimeoutSec * 1000)
    $request.set_Timeout(15000) #15 second timeout

    $response = $request.GetResponse()

    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
    $totalLengthBytes = [System.Math]::Floor($response.get_ContentLength())
    $responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $DestinationPath, Create
    $buffer = new-object byte[] 10KB
    $count = $responseStream.Read($buffer,0,$buffer.length)
    $dlkb = 0
    $downloadedBytes = $count
    $script:steps = $totalLength
    while ($count -gt 0){
       $targetStream.Write($buffer, 0, $count)
       $count = $responseStream.Read($buffer,0,$buffer.length)
       $downloadedBytes = $downloadedBytes + $count
       $dlkb = $([System.Math]::Floor($downloadedBytes/1024))
       $msg = "Downloaded $dlkb Kb of $totalLength Kb"
       $perc = (($downloadedBytes / $totalLengthBytes)*100)
       if(($perc -gt 0)-And($perc -lt 100)){
         Write-Progress -Activity $Script:ProgressTitle -Status $msg -PercentComplete $perc 
       }
    }

    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
  }catch{
    Write-Error $_
    return $false

  }finally{
    Write-Progress -Activity $Script:ProgressTitle -Completed
    Write-verbose "Downloaded $Url"
  }

  return
}
