<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


 
function Get-ProcessMemoryUsage
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$ProcessName
    )
    $ErrorActionPreference = 'Ignore'
    try {
        [array]$prcs = Get-Process "$ProcessName"

        if($prcs -eq $Null) { throw "No Such Process" }
        #"Write-Host "===============================================================================" -f DarkRed
        #Write-Host "MEMORY USAGE FOR $ProcessName" -f DarkYellow;
        #$Data = $Process | Group-Object -Property ProcessName | Format-Table Name, Count, @{n='Mem (KB)';e={'{0:N0}' -f (($_.Group|Measure-Object WorkingSet -Sum).Sum / 1KB)};a='right'} -AutoSize
        $NumProcess =$prcs.Length
        $MemoryKb = $prcs | Group-Object -Property ProcessName | % {  (($_.Group|Measure-Object WorkingSet -Sum).Sum / 1KB) }
        $MemoryMb = $prcs | Group-Object -Property ProcessName | % {  (($_.Group|Measure-Object WorkingSet -Sum).Sum / 1MB) }
        [pscustomobject]$ret = [PSCustomObject]@{
            Name = $ProcessName
            Count = $NumProcess
            MemoryKb = $MemoryKb
            MemoryMb = $MemoryMb
        }
        return $ret
    }
    catch {
        Write-Host '[ProcessMemoryUsage] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}
 
function Get-MemoryUsageForAllProcesses
{
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $ErrorActionPreference = 'Ignore'
    try {
        $high = 0
        $pmemhigh = $null
        $ProcessList = (Get-Process | Group-Object -Property ProcessName).Name
        $MemoryUsage = [System.Collections.ArrayList]::new()
        ForEach($p in $ProcessList){
            [PSCustomObject]$pmem = Get-ProcessMemoryUsage $p
            $MemoryUsage.Add($pmem) | Out-Null
            $memUsage = $pmem.MemoryKb
            if($memUsage -gt $high){
                $high = $memUsage
                $pmemhigh = $pmem
            }

        }
        Write-Verbose "Highest $pmemhigh"
        return $MemoryUsage | Sort MemoryKb -Descending
    }
    catch {
        Write-Host '[MemoryUsageForAllProcesses] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}

function Get-TopMemoryUsers
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $False)]
        [int]$Num = 5
    )
    $ErrorActionPreference = 'Ignore'
    try {
        Get-CimInstance -ClassName  WIN32_PROCESS | Sort-Object -Property ws -Descending | Select-Object -first $Num processname, @{Name="Mem Usage(MB)";Expression={[math]::round($_.ws / 1mb)}},@{Name="ProcessId";Expression={$_.ProcessId}}
   }
    catch {
        Write-Host '[TopMemoryUsers] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}


function Get-ProcessMemoryUsageDetails
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [string]$Name,
        [Parameter(Mandatory = $false)]
        [switch]$Total        
    )
    [bool]$ShowCmdline=$True

    $ErrorActionPreference = 'Ignore'
    try {
 
        $List = Get-CimInstance -ClassName  WIN32_PROCESS -Filter "Name = '$Name'" | Sort-Object -Property ws -Descending | Select-Object ProcessId, processname, @{Name="Mem Usage(MB)";Expression={[math]::round($_.ws / 1mb)}},@{Name="CmdLine";Expression={Get-ProcessCmdLineById $_.ProcessId}},@{Name="ProcessId";Expression={$_.ProcessId}}    
        $Total = ($List | measure-object 'Mem Usage(MB)' -sum).Sum
        
        if($Total){
            Write-Host '[ProcessMemoryUsageDetails] ' -n -f DarkRed
            Write-Host "Total Usage for $Name is $Total MB" -f DarkYellow
            
            $Total
        }else{
            $List    
        }
   }
    catch {
        Write-Host '[ProcessMemoryUsageDetails] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}


function Get-ProcessCmdLineById
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [int]$ProcessId
    )
    $cmdline = (Get-CimInstance Win32_Process -Filter "ProcessId = '$ProcessId'" | select CommandLine ).CommandLine    
    return $cmdline
}

function Get-ProcessCmdLine
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]$ProcessName
    )
    $ErrorActionPreference = 'Ignore'
    try {
        [array]$prcs = Get-Process "$ProcessName"

        if($prcs -eq $Null) { throw "No Such Process" }
        #"Write-Host "===============================================================================" -f DarkRed
        #Write-Host "MEMORY USAGE FOR $ProcessName" -f DarkYellow;
        #$Data = $Process | Group-Object -Property ProcessName | Format-Table Name, Count, @{n='Mem (KB)';e={'{0:N0}' -f (($_.Group|Measure-Object WorkingSet -Sum).Sum / 1KB)};a='right'} -AutoSize
        $NumProcess =$prcs.Length
        $PInfo = [System.Collections.ArrayList]::new()
        $prcs.ForEach({ $p = $_;
            $pname = $p.Name
            $processid = $p.Id
            $PMem = $p.WorkingSet
            $cmdline = (Get-CimInstance Win32_Process -Filter "ProcessId = '$processid'" | select CommandLine ).CommandLine
            [pscustomobject]$Obj = [PSCustomObject]@{
                Name = $pname
                ProcessId = $processid
                CmdLine = $cmdline
                MemoryMb = $PMem
            }
            $PInfo.Add($Obj)
            })
        return $PInfo
    }
    catch {
        Write-Host '[ProcessMemoryUsage] ' -n -f DarkRed
        Write-Host "$_" -f DarkYellow
    }
}