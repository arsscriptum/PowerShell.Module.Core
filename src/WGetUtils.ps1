<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   some utils using wget.exe
#̷𝓍   
#̷𝓍   if you don't have it, 'choco install wget' as admin
#̷𝓍   
#>


<#
#̷𝓍   Get-RedditVideo <url>         -- Downloads a Reddit Video from a post
#̷𝓍   Get-RedditAudio <url>         -- Downloads just the audio from a post
#̷𝓍   Invoke-BypassPaywall <url>    -- Bypass Paywall for the Guardian
#>


function New-RandomFilename{
<#
    .SYNOPSIS
            Create a RandomFilename 
    .DESCRIPTION
            Create a RandomFilename 
#>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Path = "$ENV:Temp",
        [Parameter(Mandatory=$false)]
        [string]$Extension = 'tmp',
        [Parameter(Mandatory=$false)]
        [int]$MaxLen = 6,
        [Parameter(Mandatory=$false)]
        [switch]$CreateFile,
        [Parameter(Mandatory=$false)]
        [switch]$CreateDirectory
    )    
    try{
        if($MaxLen -lt 4){throw "MaxLen must be between 4 and 36"}
        if($MaxLen -gt 36){throw "MaxLen must be between 4 and 36"}
        [string]$filepath = $Null
        [string]$rname = (New-Guid).Guid
        Write-Verbose "Generated Guid $rname"
        [int]$rval = Get-Random -Minimum 0 -Maximum 9
        Write-Verbose "Generated rval $rval"
        [string]$rname = $rname.replace('-',"$rval")
        Write-Verbose "replace rval $rname"
        [string]$rname = $rname.SubString(0,$MaxLen) + '.' + $Extension
        Write-Verbose "Generated file name $rname"
        if($CreateDirectory -eq $true){
            [string]$rdirname = (New-Guid).Guid
            $newdir = Join-Path "$Path" $rdirname
            Write-Verbose "CreateDirectory option: creating dir: $newdir"
            $Null = New-Item -Path $newdir -ItemType "Directory" -Force -ErrorAction Ignore
            $filepath = Join-Path "$newdir" "$rname"
        }
        $filepath = Join-Path "$Path" $rname
        Write-Verbose "Generated filename: $filepath"

        if($CreateFile -eq $true){
            Write-Verbose "CreateFile option: creating file: $filepath"
            $Null = New-Item -Path $filepath -ItemType "File" -Force -ErrorAction Ignore 
        }
        return $filepath
        
    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
}



function Invoke-BypassPaywall{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="url", Position=0)]
        [string]$Url,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="option")]
        [switch]$Option        
    )

    $WgetExe = (Getcmd wget.exe).Source
    $fn = New-RandomFilename -Extension 'html'
  
    Write-Host -n -f DarkRed "[BypassPaywall] " ; Write-Host -f DarkYellow "wget $WgetExe url $Url"

    $Content = Invoke-WebRequest -Uri "$Url"
    $sc = $Content.StatusCode    
    if($sc -eq 200){
        $cnt = $Content.Content
        Write-Host -n -f DarkRed "[BypassPaywall] " ; Write-Host -f DarkGreen "StatusCode $sc OK"
        Set-Content -Path "$fn" -Value "$cnt"
        Write-Host -n -f DarkRed "[BypassPaywall] " ; Write-Host -f DarkGreen "start-process $fn"
        start-process "$fn"
    }else{
        Write-Host -n -f DarkRed "[BypassPaywall] " ; Write-Host -f DarkYellow "ERROR StatusCode $sc"
    }
}


function Get-RedditAudio{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="url", Position=0)]
        [string]$Url,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="option")]
        [switch]$Option        
    )

    try{
        $Null =  Add-Type -AssemblyName System.webURL -ErrorAction Stop | Out-Null    
    }catch{}
    
    $urlToEncode = $Url
    $encodedURL = [System.Web.HttpUtility]::UrlEncode($urlToEncode) 

    Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkYellow "The encoded url is: $encodedURL"

    #Encode URL code ends here

    $RequestUrl = "https://www.redditsave.com/info?url=$encodedURL"
    $Content = Invoke-RestMethod -Uri $RequestUrl -Method 'GET'

    $i = $Content.IndexOf('<a onclick="gtag')
    $j = $Content.IndexOf('"/d/',$i+1)
    $k = $Content.IndexOf('"',$j+1)
    $l = $k-$j
    $NewRequest = $Content.substring($j+1,$l-1)
    $RequestUrl = "https://www.redditsave.com$NewRequest"

    Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkYellow "The encoded url is: $encodedURL"
    $WgetExe = (Getcmd wget.exe).Source

    Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkYellow "wget $WgetExe url $Url"

    $fn = New-RandomFilename -Extension 'mp4'
    $a = @("$RequestUrl","-O","$fn")
    $p = Invoke-Process -ExePath "$WgetExe" -ArgumentList $a 
    $ec = $p.ExitCode    
    if($ec -eq 0){
        $timeStr = "$($p.ElapsedSeconds) : $($p.ElapsedMs)"
        Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkGreen "Downloaded in $timeStr s"
        Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkGreen "start-process $fn"
        start-process "$fn"
    }else{
        Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkYellow "ERROR ExitCode $ec"
    }
}


function Get-RedditVideo{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="url", Position=0)]
        [string]$Url,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="option")]
        [switch]$Option        
    )

    try{
        $Null =  Add-Type -AssemblyName System.webURL -ErrorAction Stop | Out-Null    
    }catch{}
    
    $urlToEncode = $Url
    $encodedURL = [System.Web.HttpUtility]::UrlEncode($urlToEncode) 

    Write-Host -n -f DarkRed "[RedditVideo] " ; Write-Host -f DarkYellow "The encoded url is: $encodedURL"

    #Encode URL code ends here

    $RequestUrl = "https://www.redditsave.com/info?url=$encodedURL"
    $Content = Invoke-RestMethod -Uri $RequestUrl -Method 'GET'

    $i = $Content.IndexOf('"https://sd.redditsave.com/download.php')
    $j = $Content.IndexOf('"',$i+1)
    $l = $j-$i
    $RequestUrl = $Content.Substring($i+1, $l-1)
    
    $WgetExe = (Getcmd wget.exe).Source
    Write-Host -n -f DarkRed "[RedditVideo] " ; Write-Host -f DarkYellow "Please wait...."

    $fn = New-RandomFilename -Extension 'mp4'
    $a = @("$RequestUrl","-O","$fn")
    $p = Invoke-Process -ExePath "$WgetExe" -ArgumentList $a 
    $ec = $p.ExitCode    
    if($ec -eq 0){
        $timeStr = "$($p.ElapsedSeconds) : $($p.ElapsedMs)"
        Write-Host -n -f DarkRed "[RedditVideo] " ; Write-Host -f DarkGreen "Downloaded in $timeStr s"
        Write-Host -n -f DarkRed "[RedditVideo] " ; Write-Host -f DarkGreen "start-process $fn"
        start-process "$fn"
    }else{
        Write-Host -n -f DarkRed "[RedditVideo] " ; Write-Host -f DarkYellow "ERROR ExitCode $ec"
    }
}

