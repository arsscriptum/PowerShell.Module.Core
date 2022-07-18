<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

##===----------------------------------------------------------------------===
##  Timer.ps1
##===----------------------------------------------------------------------===
 
 

function Invoke-FormatElapsedTime{
 	[CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [TimeSpan]$ts
    )
    $elapsedTime = ""

    if ( $ts.Minutes -gt 0 )
    {
        $elapsedTime = [string]::Format( "{0:00} min. {1:00}.{2:00} sec.", $ts.Minutes, $ts.Seconds, $ts.Milliseconds / 10 );
    }
    else
    {
        $elapsedTime = [string]::Format( "{0:00}.{1:00} sec.", $ts.Seconds, $ts.Milliseconds / 10 );
    }

    if ($ts.Hours -eq 0 -and $ts.Minutes -eq 0 -and $ts.Seconds -eq 0)
    {
        $elapsedTime = [string]::Format("{0:00} ms.", $ts.Milliseconds);
    }

    if ($ts.Milliseconds -eq 0)
    {
        $elapsedTime = [string]::Format("{0} ms", $ts.TotalMilliseconds);
    }

    return $elapsedTime
}

function Measure-TimeBlock{

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $false,position=0)]
        [string]$Name,
        [Parameter(Mandatory = $false,position=1)]
        [ScriptBlock]$block,
        [Parameter(Mandatory = $false)]
        [switch]$Raw,
        [Parameter(Mandatory = $false)]
        [switch]$Help
    )
    if($Help -eq $True){
        Write-Host -n "[Measure-TimeBlock] " -f DarkRed
        Write-Host "Mesure command execution time" -f DarkYellow
        Write-Host -n "[Measure-TimeBlock] " -f DarkRed
        Write-Host "Measure-TimeBlock (`"My Process`")  { YOUR SCRIPT HERE }" -f DarkYellow        
        return
    }

    $Script:sw = [Diagnostics.Stopwatch]::StartNew()
    &$block
    $Script:sw.Stop()
    $time = $Script:sw.Elapsed

    $formatTime = Invoke-FormatElapsedTime $time
    if($Raw -eq $False){
        Write-Host -n "[$Name] " -f DarkRed
        Write-Host "$formatTime" -f DarkYellow
    }
    return $formatTime
}


Function Invoke-SimpleTimer {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [int]$Minutes
    )
     $MyNotifier  = 'C:\Programs\SystemTools\DownloadCompleted.exe'
    $waitsofar = 0
    $TotalSeconds = $Minutes * 60
    Log "Starting TImer with a delay of $Minutes minutes or $TotalSeconds seconds"
    $finished = $False
    do
    {

        $percent = ($waitsofar / $TotalSeconds) * 100
        Write-Progress -Activity "Testing" -Status "$percent% Complete:" -PercentComplete $percent
        Start-Sleep -Milliseconds 1000
        $waitsofar++
        if($waitsofar -ge $TotalSeconds) { $finished = $true;}
    }
    while (-not $finished)
    &$MyNotifier 
}



Function Invoke-SimpleAlarm {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [int]$Minutes
    )
    $MyNotifier  = 'C:\Programs\SystemTools\DownloadCompleted.exe'
    $waitsofar = 0
    $TotalSeconds = $Minutes * 60
    $CurrDate = (Get-Date)
    $Alarm = $CurrDate.AddMinutes($Minutes)
    Log "Starting TImer with a delay of $Minutes minutes or $TotalSeconds seconds"
    $AlarmStr = $Alarm.GetDateTimeFormats()[19]
    Log "Alarm will start at $AlarmStr"
    $finished = $False
    do
    {
        $CurrDate = (Get-Date)
        if( $CurrDate -gt $Alarm)  { $finished = $true;}
        Start-Sleep -Milliseconds 1000
    }
    while (-not $finished)
    &$MyNotifier 
}
