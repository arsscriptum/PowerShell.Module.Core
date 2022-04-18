<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

#===============================================================================
# LogConfiguration
#===============================================================================

class LogConfiguration
{
    #ChannelProperties
    [string]$Channel = 'CORE'
    [ConsoleColor]$TitleColor = 'Red'
    [ConsoleColor]$MessageColor = 'DarkGray'
    [ConsoleColor]$ErrorColor = 'DarkRed'
    [ConsoleColor]$SuccessColor = 'DarkGreen'
    [ConsoleColor]$ErrorDescriptionColor = 'DarkYellow'
}

function Get-LogConfig {
    param(
    )
    if($Script:LogConfig -eq $Null){
        $Script:LogConfig = [LogConfiguration]::new()
    }
    return $Script:LogConfig
}

  
function Write-LogError{                               
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message
    )
    $c = Get-LogConfig
    Write-InteractiveHost "[$($c.Channel)] " -f $($c.TitleColor) -NoNewLine
    Write-InteractiveHost "‼ " -f $($c.ErrorColor) -NoNewLine
    Write-InteractiveHost "$Message" -f $($c.MessageColor)
}

function Write-LogSuccess{                   
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message
    )
    $c = Get-LogConfig
    Write-InteractiveHost "[$($c.Channel)] " -f $($c.TitleColor) -NoNewLine
    Write-InteractiveHost "✔ " -f $($c.SuccessColor) -NoNewLine
    Write-InteractiveHost "$Message" -f $($c.MessageColor)
}


function Write-LogException{                              
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.ErrorRecord]$Record
    )
    $c = Get-LogConfig
    $formatstring = "{0}`n{1}"
    $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
    $ExceptMsg=($formatstring -f $fields)
    Write-InteractiveHost "[$($c.Channel)] " -f $($c.TitleColor) -NoNewLine
    Write-InteractiveHost "$ExceptMsg`n`n" -ForegroundColor DarkYellow
}

function Write-Log {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [object[]] $InputObject,
        [Parameter(Mandatory=$false)]
        [switch]$Time
    )
    $c = Get-LogConfig
    foreach ($item in $InputObject) {
        foreach ($line in ($item | Out-String)) {
            Write-InteractiveHost "[$($c.Channel)] " -f $($c.TitleColor) -NoNewLine
            if($Time){
                Write-InteractiveHost -n ("{0} | {1}" -f ((Get-Date).GetDateTimeFormats()[18]), $line) -f $($c.MessageColor)    
            }else{
                Write-InteractiveHost -n $line -f $($c.MessageColor)
            }
            
        }
    }
}

function Write-InteractiveHost {
<#
    .SYNOPSIS
        Forwards to Write-Host only if the host is interactive, else does nothing.

    .DESCRIPTION
        A proxy function around Write-Host that detects if the host is interactive
        before calling Write-Host. Use this instead of Write-Host to avoid failures in
        non-interactive hosts.

        The Git repo for this module can be found here: http://aka.ms/PowerShellForGitHub

    .EXAMPLE
        Write-InteractiveHost "Test"
        Write-InteractiveHost "Test" -NoNewline -f Yellow

    .NOTES
        Boilerplate is generated using these commands:
        # $Metadata = New-Object System.Management.Automation.CommandMetaData (Get-Command Write-Host)
        # [System.Management.Automation.ProxyCommand]::Create($Metadata) | Out-File temp
#>

    [CmdletBinding(
        HelpUri='http://go.microsoft.com/fwlink/?LinkID=113426',
        RemotingCapability='None')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification="This provides a wrapper around Write-Host. In general, we'd like to use Write-Information, but it's not supported on PS 4.0 which we need to support.")]
    param(
        [Parameter(
            Position=0,
            ValueFromPipeline,
            ValueFromRemainingArguments)]
        [System.Object] $Object,

        [switch] $NoNewline,

        [System.Object] $Separator,

        [System.ConsoleColor] $ForegroundColor,

        [System.ConsoleColor] $BackgroundColor
    )

    begin
    {
        $hostIsInteractive = ([Environment]::UserInteractive -and
            ![Bool]([Environment]::GetCommandLineArgs() -like '-noni*') -and
            ((Get-Host).Name -ne 'Default Host'))
    }

    process
    {
        # Determine if the host is interactive
        if ($hostIsInteractive)
        {
            # Special handling for OutBuffer (generated for the proxy function)
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }

            Write-Host @PSBoundParameters
        }
    }
}

