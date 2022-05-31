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



function Invoke-BypassPaywall{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="url", Position=0)]
        [string]$Url
    )

    $fn = New-RandomFilename -Extension 'html'
  
    Write-Host -n -f DarkRed "[BypassPaywall] " ; Write-Host -f DarkYellow "Invoke-WebRequest -Uri `"$Url`""

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
function Get-ChromiumShim{

    [CmdletBinding(SupportsShouldProcess)]
    param()

    $ChromiumShim="C:\Programs\Shims\cr.exe"
    return $ChromiumShim
    
    
}
<#
.SYNOPSIS
    A simple Powershell script build the module files.

.EXAMPLE
    No doc
#>
function Invoke-OnlineCall{



    [CmdletBinding()]
     param()

    $ChromeExe = (Get-ChromeApp)
    $URL = 'https://www.textnow.com/messaging'
    write-host "[Invoke-OnlineCall] " -NoNewLine -f DarkRed
    write-host "Opening TextNow at $URL with $ChromeExe" -f DarkYellow        

    start-process "$ChromeExe" -ArgumentList "$URL" 
}


function Invoke-StartWeb{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false)]
        [Alias('c')]
        [switch]$Chromium,
        [Parameter(Mandatory=$false)]
        [Alias('h')]
        [switch]$Help
    ) 
    
    $BrowserExe = (Get-ChromeApp)
    if($Chromium){ $BrowserExe =  Get-ChromiumShim ; Write-Host -n -f DarkRed "[Invoke-StartWeb] " ; Write-Host -n -f DarkYellow "Using ChromiumShim $BrowserExe" }
    $p = (Get-Item $Profile).DirectoryName
    $p = Join-Path $p 'web-start.txt'    
    if($Help){
        Write-Host -n -f DarkRed "[Invoke-StartWeb] "
        Write-Host -n -f DarkYellow "Open a page for each address in $p"
        return
    }
    $numprocess = (Get-Process chrome -EA Ignore).Count
    $KillerExe = (Get-Command 'pk.exe').Source
    if($numprocess){
        Write-Host -n -f DarkRed "[IMPORTANT] "
        Write-Host -n -f DarkYellow "kill previous chrome process? "
        $a = Read-Host '(y/n)'
        if($a -eq 'y'){ &"$KillerExe" "chrome" -n;}    
    }
    
   
    $c = Get-Content -Path $p
    
    ForEach($URL in $c){
        write-host "[Invoke-StartWeb] " -NoNewLine -f DarkRed
        write-host "Opening $URL with $BrowserExe" -f DarkYellow            
        start-process "$BrowserExe" -ArgumentList "$URL" 
    }    
    
}

function Invoke-OpenWebPage{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [Alias('h')]
        [switch]$Url,        
        [Parameter(Mandatory=$false)]
        [Alias('c')]
        [switch]$Chromium,
        [Parameter(Mandatory=$false)]
        [Alias('h')]
        [switch]$Help
    ) 
    
    $BrowserExe = (Get-ChromeApp)
    if($Chromium){ $BrowserExe =  Get-ChromiumShim ; Write-Host -n -f DarkRed "[Invoke-StartWeb] " ; Write-Host -n -f DarkYellow "Using ChromiumShim $BrowserExe" }

    write-host "[Invoke-OpenWebPage] " -NoNewLine -f DarkRed
    write-host "Opening $Url with $BrowserExe" -f DarkYellow            
    start-process "$BrowserExe" -ArgumentList "$Url" 
}


function Save-WebSiteText {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]$SiteUrl,
        [Parameter(Mandatory=$False)]
        [string]$Path,
        [Parameter(Mandatory=$False)]
        [switch]$RandomFile,
        [Parameter(Mandatory=$False)]
        [switch]$Open        
    )
    
    # Make sure $SiteUrl is a valid Url
    try {
        $SiteUrlAsUriObj = [uri]$SiteUrl
    }
    catch {
        Write-Error $_
        $global:FunctionResult = "1"
        return
    }

    if (![bool]$($SiteUrlAsUriObj.Scheme -match "http")) {
        Write-Error "'$SiteUrl' does not appear to be a URL! Halting!"
        $global:FunctionResult = "1"
        return
    }

    $pldmggFunctionsUrl = "https://raw.githubusercontent.com/pldmgg/misc-powershell/master/MyFunctions"

    if (![bool]$(Get-Command Install-Program -ErrorAction SilentlyContinue)) {
        $InstallProgramFunctionUrl = "$pldmggFunctionsUrl/Install-Program.ps1"
        try {
            Invoke-Expression $([System.Net.WebClient]::new().DownloadString($InstallProgramFunctionUrl))
        }
        catch {
            Write-Error $_
            Write-Error "Unable to load the Install-Program function! Halting!"
            $global:FunctionResult = "1"
            return
        }
    }

    try {
        $InstallProgramSplatParams = @{
            ProgramName             = "Nuget.CommandLine"
            CommandName             = "nuget"
            UseChocolateyCmdLine    = $True
            ErrorAction             = "SilentlyContinue"
            ErrorVariable           = "IPErr"
        }

        $InstallNuGetCmdLineResult = Install-Program @InstallProgramSplatParams
        if (!$InstallNuGetCmdLineResult) {throw "The Install-Program function failed!"}
    }
    catch {
        Write-Error $_
        Write-Host "Errors for the Install-Program function are as follows:"
        Write-Error $($IPErr | Out-String)
        $global:FunctionResult = "1"
        return
    }

    if (!$(Get-Command nuget -ErrorAction SilentlyContinue)) {
        Write-Error "Unable to find 'nuget.exe' after Nuget.CommandLine install! Halting!"
        $global:FunctionResult = "1"
        return
    }

    $null = nuget install htmlagilitypack

    if (!$(Test-Path "$HOME\.nuget\packages\htmlagilitypack")) {
        Write-Error "The Nuget CommandLine did not install HTML Agility Pack to '$HOME\.nuget\packages\htmlagilitypack'! Halting!"
        $global:FunctionResult = "1"
        return
    }

    $CurrentlyLoadedAssemblies = [System.AppDomain]::CurrentDomain.GetAssemblies()

    if (![bool]$($CurrentlyLoadedAssemblies.FullName -match "HtmlAgilityPack")) {
        $PathToHtmlAgilityPackDLL = $(Resolve-Path "$HOME\.nuget\packages\htmlagilitypack\*\lib\net40\HtmlAgilityPack.dll").Path
        [Reflection.Assembly]::LoadFile($PathToHtmlAgilityPackDLL)
    }
    else {
        Write-Warning "HtmlAgilityPack is already loaded!"
    }
    
    $Web = [HtmlAgilityPack.HtmlWeb]::new()
    $HtmlDoc = [HtmlAgilityPack.HtmlDocument]$Web.Load($SiteUrl)
    $TextNodes = $HtmlDoc.DocumentNode.SelectNodes("//*[not(self::script or self::style)]/text()")

    $FinalTextBlob = foreach ($node in $TextNodes) {
        if ($node.InnerText -match "[\w]") {
            $node.InnerText
        }
    }

    if($RandomFile){
        $Path = New-RandomFilename -Extension 'html'
        Set-Content -Path $Path -Value $FinalTextBlob
        Write-Host -n -f DarkRed "[Save-WebSiteText] "
        Write-Host "Saved to $Path"    
        if($Open){
            Invoke-Sublime $Path
        }
    }
    elseif($PSBoundParameters.ContainsKey("Path")){
        $Null = New-Item -Path $Path -Force -ErrorAction Ignore
        $Null = Remove-Item -Path $Path -Force -ErrorAction Ignore
        Set-Content -Path $Path -Value $FinalTextBlob
        Write-Host -n -f DarkRed "[Save-WebSiteText] "
        Write-Host "Saved to $Path"
        if($Open){
            Invoke-Sublime $Path
        }
    }
    return $FinalTextBlob
}









