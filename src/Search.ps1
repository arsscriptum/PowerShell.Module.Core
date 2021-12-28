<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

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
    $timetaken = Measure-Command -Expression { gci -Path $Path -Recurse:$Recurse -File | % { $Location = $_.Fullname ; $Name = $_.Name; $Full = $_.Fullname ; 
        if(($Location -match $String)-Or($Name -match $String)){
            $HighlightedName = ($Name | Select-String -Pattern $String -SimpleMatch); # TODO : This is a string with the pattern highlighted, but it will not show up in Format-Table
            $ResultsNum = $ResultsNum + 1
            $Details = New-Object PSObject -Property @{
                Name = $HighlightedName
                Location = $Location
            }
        $null=$Results.Add($Details)
        }
    }
    if($ResultsNum -eq 0){
        Write-Host "No matches found`n`n"
        return
    }}

    $TimeSec = $timetaken.TotalSeconds
    $TimeMS = $timetaken.TotalMilliseconds
    Write-Host "`nSearch-Item " -NoNewLine -f White
    Write-Host "Found $ResultsNum matches in $TimeSec,$TimeMS s`n" -f DarkGray -NoNewLine

    $Results | Format-Table -Autosize
    Write-Host "`n"
} 




Function Find-Item {
  # Parameters $Path and $SearchString
  param ([Parameter(Mandatory=$true, ValueFromPipeline = $true)][string]$SearchString,
  [Parameter(Mandatory=$false)][string]$Path
  )
  $cnt=0
  if($Path -eq "" -Or $Path -eq $null) { $Path = (Get-Location).Path }
  $timetaken = Measure-Command -Expression { Get-ChildItem -Path $Path -Filter $SearchString -Recurse | %{$cnt++; $f = $_; $fn = $f.Fullname ; Write-Host "$Tab -> $fn" -f Cyan | Out-Default}}
  $TimeSec = $timetaken.TotalSeconds
  $TimeMS = $timetaken.TotalMilliseconds
  Write-Host "-------------------------------------------------------" -ForegroundColor Red
  Write-Host "Found $cnt files in $TimeSec,$TimeMS s" -ForegroundColor Red
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
    [Alias('t')]
    [string]$FileType,

    [Parameter(Mandatory=$false)]
    [Alias('f')]
    [string]$Filter,

    [Parameter(Mandatory=$false)]
    [Alias('p')]
    [string]$Path,

    [Parameter(Mandatory=$false)]
    [Alias('r')]
    [switch]$Recurse=$true,
    # Code to run on file find
    [Parameter(Mandatory=$false)]
    [scriptblock]$OnFind

)   

    Write-Host "Search-Pattern (my grep): looking for a string in files. Path: $Path" -f DarkGreen
    Write-Host "  Pattern: $Pattern" -f DarkGreen

    if($Path -eq $null -Or $Path.Length -eq 0){
        $Path = (Get-Location).Path
    }

    if($Filter -ne $null -And $Filter.Length -gt 0){
        Write-Host "  Using filter: $Filter" -f DarkGreen
    }
    if($FileType -ne $null -And $FileType.Length -gt 0){
        $Filter = '*.' + $FileType
        Write-Host "  Using filter from file types: $Filter" -f DarkGreen
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
