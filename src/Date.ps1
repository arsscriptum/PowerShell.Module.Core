<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Get-DateString([switch]$Verbose){
<#
    .SYNOPSIS
            Get Date
    .DESCRIPTION
           Get Date
#>    

    if($Verbose){
        return ((Get-Date).GetDateTimeFormats()[8]).Replace(' ','_').ToString()
    }

    $curdate = $(get-date -Format "yyyy-MM-dd_\hhh-\mmmm-\sss")
    return $curdate 
}

function Get-DateFormat{
<#
    .SYNOPSIS
            Get Date Formats
    .DESCRIPTION
           Get Date Formats
#> 
    return (Get-Date).GetDateTimeFormats()
}


function ConvertFrom-Ctime ([Int64]$ctime) {
<#
    .SYNOPSIS
        FROM C-time converter function
    .DESCRIPTION
        Simple function to convert FROM Unix/Ctime into EPOCH / "friendly" time
#> 
    [datetime]$epoch = '1970-01-01 00:00:00'    
    [datetime]$result = $epoch.AddSeconds($Ctime)
    return $result
}


function ConvertTo-CTime ([datetime]$InputEpoch) {
<#
    .SYNOPSIS
        INTO C-time converter function
    .DESCRIPTION
        Simple function to convert into FROM EPOCH / "friendly" into Unix/Ctime, which the Inventory Service uses.
#> 
    [datetime]$Epoch = '1970-01-01 00:00:00'
    [int64]$Ctime = 0

    $Ctime = (New-TimeSpan -Start $Epoch -End $InputEpoch).TotalSeconds
    return $Ctime
}

function ConvertFrom-UnixTime{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [Int64]$UnixTime
    )
    begin {
        $epoch = [DateTime]::SpecifyKind('1970-01-01', 'Utc')
    }
    process {
        $epoch.AddSeconds($UnixTime)
    }
}

function ConvertTo-UnixTime {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [DateTime]$DateTime
    )
    begin {
        $epoch = [DateTime]::SpecifyKind('1970-01-01', 'Utc')
    }
    process {
        [Int64]($DateTime.ToUniversalTime() - $epoch).TotalSeconds
    }
}

function Get-UnixTime {
    $Now = Get-Date
    return ConvertTo-UnixTime $Now
}

