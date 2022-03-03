<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

<#
    .SYNOPSIS
    Invoke Start-Process on a URL

    .DESCRIPTION
    Invoke Start-Process on a URL to make a web search with specified query and search engine.  For quicker usage, use "New-Alias" to set an alias to "Invoke-Web-Search"

    .PARAMETER Query
    The search term to query

    .PARAMETER SelectSearchEngine
    To specify a search engine (default to Google)

    .EXAMPLE 

    >> This will to a generic search on the film Star Wars
       .\Invoke-Web-Search.ps1 -Query "Star Wars"


    >> This will to let you specify a search engine,upon selecting Pirate Bay, will do a torrent search on the film Star Wars
       .\Invoke-Web-Search.ps1 -Query "Star Wars" -e


#>

 

function Get-ChromeApp{

    [CmdletBinding(SupportsShouldProcess)]
    param()

    $expectedLocations="$ENV:ProgramFiles\Google\Chrome\Application", "${ENV:ProgramFiles(x86)}\Google\Chrome\Application"
    $chromeFiles=$expectedLocations|%{Join-Path $_ 'chrome.exe'}
    [String[]]$validChromeFiles=@($chromeFiles|?{test-path $_})
    $validChromeFilesCount = $validChromeFiles.Count
    if($validChromeFilesCount){
        return $validChromeFiles[0]
    }
    else{
        return $Null
    }
}

function Invoke-OnlineCall{
    [CmdletBinding(SupportsShouldProcess)]
     param()

    $ChromeExe = (Get-ChromeApp)
    $URL = 'https://www.textnow.com/messaging'
    write-host "[Invoke-OnlineCall] " -NoNewLine -f DarkRed
    write-host "Opening TextNow at $URL with $ChromeExe" -f DarkYellow        

    start-process "$ChromeExe" -ArgumentList "$URL" 
}