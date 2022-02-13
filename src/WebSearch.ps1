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
         [Alias('e','engine')]
         [switch]$SearchEngine
     )

    $Engine = 0
    if($SearchEngine){
        write-host "[Invoke-WebSearch] " -NoNewLine -f DarkRed
        write-host "Select Search Engine in choices below" -f DarkYellow        
        $Engine = Select-SearchEngine    
    }

    $URL = New-SearchUrl $Query $Engine

    Write-Host "Searching Internet for '$Query' ($URL)" -ForeGroundColor Red
    start-process "$URL" 

}
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3KWaYqxLlrR5W286JexqdWPT
# CXKgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0yMjAyMDkyMzI4NDRaFw0zOTEyMzEyMzU5NTlaMCUxIzAhBgNVBAMTGkFyc1Nj
# cmlwdHVtIFBvd2VyU2hlbGwgQ1NDMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
# CgKCAQEA60ec8x1ehhllMQ4t+AX05JLoCa90P7LIqhn6Zcqr+kvLSYYp3sOJ3oVy
# hv0wUFZUIAJIahv5lS1aSY39CCNN+w47aKGI9uLTDmw22JmsanE9w4vrqKLwqp2K
# +jPn2tj5OFVilNbikqpbH5bbUINnKCDRPnBld1D+xoQs/iGKod3xhYuIdYze2Edr
# 5WWTKvTIEqcEobsuT/VlfglPxJW4MbHXRn16jS+KN3EFNHgKp4e1Px0bhVQvIb9V
# 3ODwC2drbaJ+f5PXkD1lX28VCQDhoAOjr02HUuipVedhjubfCmM33+LRoD7u6aEl
# KUUnbOnC3gVVIGcCXWsrgyvyjqM2WQIDAQABo3YwdDATBgNVHSUEDDAKBggrBgEF
# BQcDAzBdBgNVHQEEVjBUgBD8gBzCH4SdVIksYQ0DovzKoS4wLDEqMCgGA1UEAxMh
# UG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZpY2F0ZSBSb290ghABvvi0sAAYvk29NHWg
# Q1DUMAkGBSsOAwIdBQADggEBAI8+KceC8Pk+lL3s/ZY1v1ZO6jj9cKMYlMJqT0yT
# 3WEXZdb7MJ5gkDrWw1FoTg0pqz7m8l6RSWL74sFDeAUaOQEi/axV13vJ12sQm6Me
# 3QZHiiPzr/pSQ98qcDp9jR8iZorHZ5163TZue1cW8ZawZRhhtHJfD0Sy64kcmNN/
# 56TCroA75XdrSGjjg+gGevg0LoZg2jpYYhLipOFpWzAJqk/zt0K9xHRuoBUpvCze
# yrR9MljczZV0NWl3oVDu+pNQx1ALBt9h8YpikYHYrl8R5xt3rh9BuonabUZsTaw+
# xzzT9U9JMxNv05QeJHCgdCN3lobObv0IA6e/xTHkdlXTsdgxggHhMIIB3QIBATBA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdAIQ
# mkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU+eN8aHwvEt4rKtEpIA3h
# /1kbFzIwDQYJKoZIhvcNAQEBBQAEggEAwxluuyWhPbET5Ajdpr7MiZK4RI2UFNJD
# 0yBJwfp5nhVf3wtGIrCHlUVDaXnIFcYZ4ljvraCuFbAPEa26jCLTHhV+NE9CiW1/
# OHhnDUF0MyYd7Sr3zHD7qbgqJ3g0kwMb5O1RzbdFUF0MDujyz94d9WHc+SVGn6+1
# 8IJZ8UNXXcrsR4oKs5yAgCjcCRfnTDN3/o3lCQEreXy704GNaXg+Lj/N+hfaMxJL
# zNr0IcB2x2uWiMjqwPNQyupTuUnGWsD7xVzEw8+5ajQQcYQImNUnZ8ryizG/ZWaK
# EKFbrP3GwPxNtRa0umLfyTSANMX2ijTJ3mBfQCS+TQeMC126jJsl3g==
# SIG # End signature block
