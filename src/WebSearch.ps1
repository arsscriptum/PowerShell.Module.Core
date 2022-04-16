<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
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




function Select-SearchEngine {      # NOEXPORT
    # PromptForChoice Args


    $ggl = New-Object System.Management.Automation.Host.ChoiceDescription "&Google", "Search with Google Search Engine"
    $ddg = New-Object System.Management.Automation.Host.ChoiceDescription "&DuckDuckGo", "Search with DuckDuckGo Search Engine"
    $bng = New-Object System.Management.Automation.Host.ChoiceDescription "&Bing", "Search with Bing Search Engine"
    $alt = New-Object System.Management.Automation.Host.ChoiceDescription "&AltaVista", "Search with AltaVista Search Engine"
    $prb = New-Object System.Management.Automation.Host.ChoiceDescription "&PirateBay", "Search with PirateBay Search Engine"
    $Choices = [System.Management.Automation.Host.ChoiceDescription[]]($ggl,$ddg,$bng,$alt,$prb)
    $Default = 0
    # Prompt for the choice
    $Choice = $host.UI.PromptForChoice("", "", $Choices, $Default)
    
    return $Choice
}

function New-SearchUrl($Query, $SearchEngineId){
    $result = ""
    switch ( $SearchEngineId ){
        0 { $result = "www.google.com/search?q=$Query"}
        1 { $result = "https://duckduckgo.com/?q=$Query&ia=web"}
        2 { $result = "www.bing.com/search?q=$Query"}
        3 { $result = "https://ca.search.yahoo.com/search?p=$Query&fr2=sa-gp-search&fr=sfp"}
        4 { $result = "https://thepiratebay.org/search.php?q=$Query&all=on&search=Pirate+Search&page=0&orderby="}
        default { $result = "www.google.com/search?q=$Query"}
    }
    return  $result;
}

function Invoke-WebSearch{
    [CmdletBinding(SupportsShouldProcess)]
     param(
         [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="Search query to send on the web") ]
         [Alias('q')]
         [ValidateNotNullOrEmpty()]
         [string]$Query,
         [Parameter(Mandatory=$false)]
         [Alias('e')]
         [switch]$SearchEngine,
         [Parameter(Mandatory=$false)]
         [Alias('t')]
         [switch]$Torrent         
     )

    if ($PSBoundParameters.ContainsKey('Engine')) {
        Write-Host '[Invoke-WebSearch] ' -f DarkRed -NoNewLine
        Write-Host "Verbose OUTPUT" -f Yellow            
        $ArgumentList += " /V"
    }

    $EngineId = 0
    if($SearchEngine){
        write-host "[Invoke-WebSearch] " -NoNewLine -f DarkRed
        write-host "Select Search Engine in choices below" -f DarkYellow        
        $EngineId = Select-SearchEngine    
    }

    if($Torrent) {
        write-host "[Invoke-WebSearch] " -NoNewLine -f DarkRed
        write-host "USING TORRENT SEARCH" -f DarkYellow        
        $EngineId = 4 ; 
  
    }

    $URL = New-SearchUrl $Query $EngineId

    Write-Host "Searching Internet for '$Query' ($URL)" -ForeGroundColor Red
    start-process "$URL" 

}



