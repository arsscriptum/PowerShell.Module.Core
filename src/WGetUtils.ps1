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


function Get-WGetExecutable{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="option")]
        [switch]$Option        
    )

    $Cmd = Get-Command -Name 'wget.exe' -ErrorAction Ignore
    if($Cmd -eq $Null) { throw "Cannot find wget.exe" }
    $WgetExe = $Cmd.Source
    if(-not(Test-Path $WgetExe)){ throw "cannot find wget" }
    return $WgetExe
}



function Save-RedditAudio{
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
    $WgetExe = Get-WGetExecutable

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


function Save-RedditVideo{
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
    
    $WgetExe = Get-WGetExecutable
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
