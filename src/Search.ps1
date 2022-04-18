<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Find-Item {
    param([Parameter(Mandatory = $true)][string]$SearchString, [ValidateSet('Any', 'All')][string]$SearchType = "All", [int]$Depth = [int]::MaxValue)
    
    $SearchSegments = ($SearchString -replace "\W", "|").Split("|")
    $SearchResults = foreach ($Segment in $SearchSegments) { Get-ChildItem . -Recurse -Depth $Depth -Filter "*$Segment*" }
    
    if ($SearchType -eq "Any") {
        Write-Host "Searching for files matching Any of the following words:" -ForegroundColor Cyan
        Write-Host $SearchSegments
        $global:MatchedResults = $SearchResults
    }

    if ($SearchType -eq "All") {
        Write-Host "Searching for files matching All of the following words:" -ForegroundColor Cyan
        Write-Host $SearchSegments
        $global:MatchedResults = foreach ($Result in $SearchResults) {
            $IsMatch = $true
            for ($i = 0; $i -lt $SearchSegments.Count; $i++) {
                if ($Result.Name -notlike "*$($SearchSegments[$i])*") { $IsMatch = $false }
            }
            if ($IsMatch) { $Result }
        }
    }    

    if ($MatchedResults.Count -gt 0) {
        $FilteredResults = @()
        foreach ($MatchedResult in $MatchedResults) { if ($FilteredResults.FullName -notcontains $MatchedResult.FullName) { $FilteredResults += $MatchedResult } }
        Write-Host "Found the below [$($FilteredResults.Count)] result(s) for [$SearchSegments]:" -ForegroundColor Green
        Write-Host ($FilteredResults | Select-Object Name, @{N = "Type"; E = { if ($_.PSIsContainer) { "Folder" }else { $_.Extension } } }, @{N = "Directory"; E = { $_.Directory } }, FullName | Out-String).Trim() -ForegroundColor Cyan
    }
    else {
        Write-Host "No results for [$SearchSegments]." -ForegroundColor Yellow
    }
}

function Search-Item{

    # Define Parameters
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$String,
        [Parameter(Mandatory=$False,Position=1)]
        [string]$Path="",
        [Parameter(Mandatory=$False)]
        [switch]$Recurse,
        [Parameter(Mandatory=$false)]
        [switch]$Quiet
    )   


    if($Path -eq ""){
        $Path = (Get-Location).Path
    }elseif(-not(Test-Path -Path $Path -PathType Container)){ 
        throw "Invalid Path specified."
    }
    if($Quiet -ne $true){
        Write-Host "Search-Item " -NoNewLine -f White
        Write-Host "Search for a name matching " -f DarkGray -NoNewLine
        Write-Host "$String.`n" -f Gray        
    }


    $ResultsNum = 0
    $Results = [System.Collections.ArrayList]::new()
    $timetaken = Measure-Command -Expression { gci -Path $Path -Recurse:$Recurse | % { $Location = $_.Fullname ; $Name = $_.Name; $Full = $_.Fullname ; $Length = $_.Length ; 
        if(($Location -match $String)-Or($Name -match $String)){
            $HighlightedName = ($Name | Select-String -Pattern $String -SimpleMatch); # TODO : This is a string with the pattern highlighted, but it will not show up in Format-Table
            $ResultsNum = $ResultsNum + 1
            $Details = New-Object PSObject -Property @{
                Name = $HighlightedName
                Location = $Location
                Length = $Length
            }
            $null=$Results.Add($Details)
        }
    }
    if($ResultsNum -eq 0){
        Write-Host "No matches found`n`n"
        return
    }}

    $Sum = $Results | measure-object -property Length -sum
    $TimeSec = $timetaken.TotalSeconds
    $TimeMS = $timetaken.TotalMilliseconds
    Write-Host "`nSearch-Item " -NoNewLine -f White
    Write-Host "Found $ResultsNum matches in $TimeSec,$TimeMS s`n" -f DarkGray -NoNewLine

    $Results | Format-Table -Autosize
    Write-Host "`n"
} 



function Search-Files{

    # Define Parameters
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$String,
        [Parameter(Mandatory=$False,Position=1)]
        [string]$Path="",
        [Parameter(Mandatory=$False)]
        [switch]$Recurse,
        [Parameter(Mandatory=$false)]
        [switch]$Quiet
    )   


    if($Path -eq ""){
        $Path = (Get-Location).Path
    }elseif(-not(Test-Path -Path $Path -PathType Container)){ 
        throw "Invalid Path specified."
    }
    if($Quiet -ne $true){
        Write-Host "Search-Files " -NoNewLine -f White
        Write-Host "Search for a name matching " -f DarkGray -NoNewLine
        Write-Host "$String.`n" -f Gray        
    }


    $ResultsNum = 0
    $Results = [System.Collections.ArrayList]::new()
    try{
    $timetaken = Measure-Command -Expression { gci -Path $Path -Recurse:$Recurse -File -ErrorAction Stop | % { $Location = $_.Fullname ; $Name = $_.Name; $Full = $_.Fullname ; $Length = $_.Length ; 
        if(($Location -match $String)-Or($Name -match $String)){
            $HighlightedName = ($Name | Select-String -Pattern $String -SimpleMatch); # TODO : This is a string with the pattern highlighted, but it will not show up in Format-Table
            $ResultsNum = $ResultsNum + 1
            $Details = New-Object PSObject -Property @{
                Name = $HighlightedName
                Location = $Location
                Length = $Length
            }
            $null=$Results.Add($Details)
        }
    }
    if($ResultsNum -eq 0){
        Write-Host "No matches found`n`n"
        return
    }}
    }catch
    { 
        Write-Host "[ERROR] " -n -f DarkRed ; Write-Host "$_" -f DarkYellow ; 
    }
    $count = $Results.count
    $sum = $Results | measure-object -property Length -sum
    if($sum.sum -ge 1073741824)
        {
        $totalGB = [math]::round($sum.sum/1073741824, 2)
        write-Host "$count files using a total of $totalGB GB"  -f DarkRed
        }
    elseif(($sum.sum -ge 1048576) -and ($sum.sum -lt 1073741824))
        {
        $totalMB = [math]::round($sum.sum/1048576, 2)
        write-Host "$count files using a total of $totalMB MB" -f DarkYellow 
        }
    elseif($sum.sum -lt 1048576)
        {
        $totalKB = [math]::round($sum.sum/1024, 2)
        write-Host "$count files using a total of $totalKB KB"  -f DarkYellow 
        }
    
    $TimeSec = $timetaken.TotalSeconds
    $TimeMS = $timetaken.TotalMilliseconds
    Write-Host "`nSearch-Item " -NoNewLine -f White
    Write-Host "Total Size $Sum" -f DarkGray -NoNewLine
    Write-Host "Found $ResultsNum matches in $TimeSec,$TimeMS s`n" -f DarkGray -NoNewLine

    $Results | Format-Table -Autosize
    Write-Host "`n"
} 



function Search-Pattern
{
<#
    .SYNOPSIS
            Cmdlet to find in files (grep)
    .DESCRIPTION
            Cmdlet to find in files (grep)
    .PARAMETER Pattern
            What to look for in the files
    .PARAMETER Filter
            File filter
    .PARAMETER Path
            Where to search
    .EXAMPLE
        Find-In-Files.ps1 -Pattern 'create' -Filter '*.ps1'
        Find-In-Files.ps1 -Pattern 'create' -Filter '*.ps1' | Out-Gridview
#>

# Define Parameters
[CmdletBinding()]
Param
(
    [Parameter(Position = 0,Mandatory=$true)]
    [Object]$Pattern,

    [Parameter(Mandatory=$false)]
    [Alias('e')]
    [string]$Extension,

    [Parameter(Mandatory=$false)]
    [Alias('p')]
    [string]$Path,

    [Parameter(Mandatory=$false)]
    [Alias('r')]
    [switch]$Recurse=$true

)   

    Write-Host "Search-Pattern (my grep): looking for a string in files. Path: $Path" -f DarkGreen
    Write-Host "  Pattern: $Pattern" -f DarkGreen

    if($Path -eq $null -Or $Path.Length -eq 0){
        $Path = (Get-Location).Path
    }

    $Filter = '*.*'
    if($Extension -ne $null -And $Extension.Length -gt 0){
        $Filter = '*.' + $Extension
        Write-Host "  Using Extension filter: $Filter" -f DarkGreen
    }

    if($Recurse)
    {
        Write-Host "  Recurse: YES" -f DarkYellow
        Get-ChildItem -Path $Path -Filter $Filter -recurse | Select-String -pattern $Pattern
    }
    else
    {
        Write-Host "  Recurse: NO" -f DarkYellow
        Get-ChildItem -Path $Path -Filter $Filter | Select-String -pattern $Pattern
    }
}
