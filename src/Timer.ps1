

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

