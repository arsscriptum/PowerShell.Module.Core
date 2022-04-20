<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   Service
#̷𝓍   
#̷𝓍   <guillaumeplante.qc@gmail.com>
#̷𝓍   https://arsscriptum.github.io/
#>




function AutoUpdateProgress {   # NOEXPORT
    $Len = $Global:ServiceName.Length
    $Diff = 50 - $Len
    For($i = 0 ; $i -lt $Diff ; $i++){ $Global:ServiceName += '.'}
    $Global:ProgressMessage = "$Global:ServiceName... ( $Global:StepNumber on $Global:TotalSteps) (W) by $Global:User $Global:FoundCount"
    Write-Progress -Activity $Global:ProgressTitle -Status $Global:ProgressMessage -PercentComplete (($Global:StepNumber / $Global:TotalSteps) * 100)

}

function CheckAdmin {
    #This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
        return $False
    }
    return $True
}



function Disable-Service
{
<#
	.SYNOPSIS
		Get-ScriptDirectory returns the proper location of the script.

	.OUTPUTS
		System.String
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Name
        )

    Try{

        Write-ChannelMessage "Disable-Service $Name"
        $ServicePtr = Get-Service -Name $Name -ErrorAction Ignore
        if($ServicePtr -eq $Null){
            throw "INVALID SERVICE NAME"
        }
        Write-ChannelMessage "Stopping service $Name"
        Stop-Service -Name $Name -ErrorAction Ignore
        Write-ChannelResult "Stopped."
        Write-ChannelMessage "Setting StartupType to Disabled"
        Set-Service -Name $Name -StartupType Disabled -ErrorAction Ignore
        Write-ChannelResult "StartupType set to Disabled"

        $ServicePtr = Get-Service -Name $Name -ErrorAction Ignore
        if($ServicePtr -eq $Null){
            throw "INVALID SERVICE NAME"
        }

        $ServicePtr | Select *
    }catch [Exception]{
        Write-Host '[ERROR] ' -f DarkRed -NoNewLine
        Write-Host " Disable-Service $_" -f DarkYellow
    }

}

function List-WriteableServices
{
<#
    .SYNOPSIS
        Get-ScriptDirectory returns the proper location of the script.

    .OUTPUTS
        System.String
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [String]$User,
        [Parameter(Mandatory=$false)]
        [String]$ServiceName,        
        [Parameter(Mandatory=$false)]
        [switch]$NoProgress        
    )

    Try{

        Write-Verbose "List-WriteableServices $Name"
        if ($PSBoundParameters.ContainsKey('ServiceName')) {
            [array]$ServiceList = (Get-Service | where Name -match "$ServiceName").Name
        }else{
            [array]$ServiceList = (Get-Service).Name
        }
        
        if($ServiceList -eq $Null){
            throw "INVALID SERVICE NAME"
        }
        $ServiceListLen = $ServiceList.Length
        $AccessChkExe = (Get-Command 'accesschk.exe').Source
        $WriteableServices = [System.Collections.ArrayList]::new()        
        $Global:ProgressTitle = 'ANALYSING SERVICES'
        $Global:StepNumber = 0
        $Global:TotalSteps = $ServiceListLen
        $Global:ErrorList = [System.Collections.ArrayList]::new()
        $Global:ErrorCount = 0
        $Global:User = $User
        $Global:FoundCount = 0
        if( $NoProgress -eq $False ) { AutoUpdateProgress }
        For($i = 0 ; $i -lt $ServiceListLen ; $i++){
            $Global:ServiceName = $ServiceList[$i]
            Write-Verbose "Checking $Global:ServiceName"
            $SvcUsers = &"$AccessChkExe" -c $ServiceList[$i] -w -nobanner
            $SvcUsersLen = $SvcUsers.Length
            $Global:StepNumber++
            For($j = 1 ; $j -lt $SvcUsersLen ; $j++){
                if($SvcUsers[$j] -match $User){
                    $Null = $WriteableServices.Add($ServiceList[$i])
                    $Global:FoundCount++
                    Write-Verbose "Service $Global:ServiceName WRITEABLE by $User"
                }
            }
            if( $NoProgress -eq $False ) { AutoUpdateProgress }
        }
        
        return $WriteableServices
    }catch [Exception]{
        [System.Management.Automation.ErrorRecord]$Record = $_
        $formatstring = "{0}`n{1}"
        $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
        $ExceptMsg=($formatstring -f $fields)  
        $Global:ErrorCount++
        $null=$Global:ErrorList.Add($ExceptMsg) 
    }

}
