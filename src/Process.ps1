
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



##===----------------------------------------------------------------------===
##  Invoke-Process.ps1 - PowerShell script
##
##  Invoke-Process is a simple wrapper funct that aims to "PowerShellyify" 
##  launching typical external processes. There are lots of ways to invoke 
##  processes in PowerShell with Start-Process, Invoke-Expression, & and others
##  but none account well for the various streams and exit codes that an external 
##  process returns. Also, it's hard to write good tests when launching external 
##  proceses.
##
##  This func ensures any errors are sent to the error stream, standard output is 
##  sent via the Output stream and any time the process returns an exit code other 
##  than 0, treat it as an error.
##
##  Guillaume Plante <radicaltronic@gmail.com>
##  Copyright(c) All rights reserved.
##===----------------------------------------------------------------------===
 

function Invoke-CheckScreenSaver
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        #[Parameter(Mandatory = $True, Position=0)]
        #[ValidateNotNullOrEmpty()]$ExePath,
        [Parameter(Mandatory = $False)]
        [string]$WorkingDirectory
    )
    $ErrorActionPreference = 'Stop'
    $LogFile =  New-RandomFilename -Path 'x:\Log\ScreenSaver' -CreateFile -Extension 'log'
    #$Null = Remove-Item -Path $LogFile -Force -ErrorAction Ignore
    #$Null = New-Item -Path $LogFile -Force -ErrorAction Ignore
    $CurrDateSeconds = Get-Date -UFormat %s
    $LastCheckTime = Get-Date -UFormat %s
    $CurrDate = (Get-Date).GetDateTimeFormats()[9]
    $LogContent = "ScreenSaver Check has started on $CurrDate"
    Add-Content -Path $LogFile -Value $LogContent
    $AllProcesses = (Get-CIMInstance –Class Win32_Process).Name
    $AllProcessesCount = $AllProcesses.Count
    if($AllProcessesCount -lt 1){
        Write-Warning "No Process found"
        return;
    }
    $CurrentTimeSpent = $LastCheckTime - $CurrDateSeconds
    if($CurrentTimeSpent -gt 60){
        $LogContent = "ScreenSaver is still running. Current time is $CurrDate"
        Add-Content -Path $LogFile -Value $LogContent
    }
    $FoundScreenSaver = $False
    ForEach($p in $AllProcesses){
        $i = $p.LastIndexOf('.')
        $l = $p.Length
        $Ext = $p.SubString($i,4)
        if($Ext -eq '.scr'){
            $FoundScreenSaver = $True
        }
    }

 }
function Invoke-Process
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True, Position=0)]
        [ValidateNotNullOrEmpty()]$ExePath,
        [Parameter(Mandatory = $True, Position=1)]
        [string[]]$ArgumentList,
        [Parameter(Mandatory = $False)]
        [string]$WorkingDirectory,
        [Parameter(Mandatory = $False)]
        [System.Management.Automation.PSCredential]$Credential
    )
    $ErrorActionPreference = 'Stop'

    if(($WorkingDirectory -eq $null) -Or ($WorkingDirectory.Length -eq 0)){
        $WorkingDirectory=(Get-Location).Path
    
    }
    $UseSuppliedCredentials=$False

    if ($Credential -ne $null){
            
            $UseSuppliedCredentials = $True

            $u=$Credential.UserName
            $p=$Credential.GetNetworkCredential().Password
            Write-Verbose "Using suplied creds. $u $p"
           
    }
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        
        $FNameOut = New-RandomFilename -Extension 'log' -CreateDirectory
        $FNameErr = New-RandomFilename -Extension 'log' -CreateDirectory

        $startProcessParams = @{
            FilePath               = $ExePath
            RedirectStandardError  = $FNameErr
            RedirectStandardOutput = $FNameOut
            Wait                   = $true
            PassThru               = $true
            NoNewWindow            = $true
            WorkingDirectory       = $WorkingDirectory
        }

        $cmdName=""
        $cmdId=0
        $cmdExitCode=0
        $cmdTotalProcessorTime=0
        if ($PSCmdlet.ShouldProcess("Process [$($ExePath)]", "Run with args: [$($ArgumentList)]")) {
            if ($ArgumentList) {
                Write-Verbose -Message "Invoke-Process -ExePath $ExePath -ArgumentList $ArgumentList"
                if($UseSuppliedCredentials){
                    Write-Verbose -Message "RUN Start-Process Level 1"
                    [System.Diagnostics.Process]$cmd = Start-Process @startProcessParams -ArgumentList $ArgumentList -Credential $Credential
                    $cmdExitCode = $cmd.ExitCode
                    $cmdId = $cmd.Id 
                    $cmdHasExited=$cmd.HasExited 
                    $cmdTotalProcessorTime=$cmd.TotalProcessorTime 
                }
                else{
                    Write-Verbose -Message "RUN Start-Process Level 2"
                    $cmd = Start-Process @startProcessParams -ArgumentList $ArgumentList
                    $cmdExitCode = $cmd.ExitCode
                    $cmdId = $cmd.Id 
                    $cmdHasExited=$cmd.HasExited 
                    $cmdTotalProcessorTime=$cmd.TotalProcessorTime 
                }
            
            }
            else {
                Write-Verbose -Message "RUN Start-Process Level 3"
                $cmd = Start-Process @startProcessParams
                $cmdExitCode = $cmd.ExitCode
                $cmdId = $cmd.Id 
                $cmdHasExited=$cmd.HasExited 
                $cmdTotalProcessorTime=$cmd.TotalProcessorTime 
            }

            Write-Verbose -Message "Results cmdExitCode $cmdExitCode cmdId $cmdId cmdName $cmdName"
            Write-Verbose -Message "Results cmd $cmd"


            $stdOut = Get-Content -Path $FNameOut -Raw
            $stdErr = Get-Content -Path $FNameErr -Raw
            if ([string]::IsNullOrEmpty($stdOut) -eq $false) {
                $stdOut = $stdOut.Trim()
            }
            if ([string]::IsNullOrEmpty($stdErr) -eq $false) {
                $stdErr = $stdErr.Trim()
            }
            $res = [PSCustomObject]@{
                HasExited          = $cmdHasExited
                TotalProcessorTime = $cmdTotalProcessorTime
                Id                 = $cmdId
                ExitCode           = $cmdExitCode
                Output             = $stdOut
                Error              = $stdErr
                ElapsedSeconds     = $stopwatch.Elapsed.Seconds
                ElapsedMs          = $stopwatch.Elapsed.Milliseconds
            }
            
            return $res
        }
    }
    catch {
        Show-ExceptionDetails $_
    }
    finally {
        $Null = Remove-Item -Path $FNameOut -Force -ErrorAction Ignore
        $Null = Remove-Item -Path $FNameErr -Force -ErrorAction Ignore
    }
}
 
