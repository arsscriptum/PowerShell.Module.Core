
<#
#ฬท๐   ๐๐ก๐ข ๐ข๐๐ก๐๐๐ฃ๐ค๐
#ฬท๐   ๐ตโโโโโ๐ดโโโโโ๐ผโโโโโ๐ชโโโโโ๐ทโโโโโ๐ธโโโโโ๐ญโโโโโ๐ชโโโโโ๐ฑโโโโโ๐ฑโโโโโ ๐ธโโโโโ๐จโโโโโ๐ทโโโโโ๐ฎโโโโโ๐ตโโโโโ๐นโโโโโ ๐งโโโโโ๐พโโโโโ ๐ฌโโโโโ๐บโโโโโ๐ฎโโโโโ๐ฑโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐บโโโโโ๐ฒโโโโโ๐ชโโโโโ๐ตโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐ณโโโโโ๐นโโโโโ๐ชโโโโโ.๐ถโโโโโ๐จโโโโโ@๐ฌโโโโโ๐ฒโโโโโ๐ฆโโโโโ๐ฎโโโโโ๐ฑโโโโโ.๐จโโโโโ๐ดโโโโโ๐ฒโโโโโ
#>



function Get-BatteryLevel {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$false)]
        [switch]$ShowStatusBar, 
        [Parameter(Mandatory=$false)]
        [int]$StatusBarTime = 3
    )  
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

    if($ShowStatusBar){
        while($StatusBarTime){
            Write-Progress -Activity "Power" -Status "Power Status" -PercentComplete $PercentBattery
            Sleep 1
            $StatusBarTime--
        }
    }

    
    return $PercentBattery
}


function AutoUpdateProgress {   # NOEXPORT
    $Len = $Global:ServiceName.Length
    $Diff = 50 - $Len
    For($i = 0 ; $i -lt $Diff ; $i++){ $Global:ServiceName += '.'}
    $Global:ProgressMessage = "$Global:ServiceName... ( $Global:StepNumber on $Global:TotalSteps) (W) by $Global:User $Global:FoundCount"
    Write-Progress -Activity $Global:ProgressTitle -Status $Global:ProgressMessage -PercentComplete (($Global:StepNumber / $Global:TotalSteps) * 100)

}
