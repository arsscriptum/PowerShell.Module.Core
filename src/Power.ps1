<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.Core            
  ║   
  ║   Power.ps1
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>

function Get-BatteryLevel {
    [CmdletBinding(SupportsShouldProcess)]
    param ()  
    [int]$PercentBattery = 0
    $WmicExe = (get-command wmic).Source  
    [array]$PowerData=  &"$WmicExe" "PATH" "Win32_Battery" "Get" "EstimatedChargeRemaining"
    $PowerDataLen = $PowerData.Length
    $Data = [System.Collections.ArrayList]::new();
    ForEach($line in $PowerData){
        if($line.Length) { $Null=$Data.Add($line); } 
    }
    if( $Data.Count -eq 2 ){
        $PercentBattery = $Data[1]
    }

    Write-Progress -Activity "Power" -Status "Power Status" -PercentComplete $PercentBattery



    return $PercentBattery
}


function AutoUpdateProgress {   # NOEXPORT
    $Len = $Global:ServiceName.Length
    $Diff = 50 - $Len
    For($i = 0 ; $i -lt $Diff ; $i++){ $Global:ServiceName += '.'}
    $Global:ProgressMessage = "$Global:ServiceName... ( $Global:StepNumber on $Global:TotalSteps) (W) by $Global:User $Global:FoundCount"
    Write-Progress -Activity $Global:ProgressTitle -Status $Global:ProgressMessage -PercentComplete (($Global:StepNumber / $Global:TotalSteps) * 100)

}
