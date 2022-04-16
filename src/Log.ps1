<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

#===============================================================================
# ChannelProperties
#===============================================================================

class ChannelProperties
{
    #ChannelProperties
    [string]$Channel = 'CORE'
    [ConsoleColor]$TitleColor = (Get-RandomColor)
    [ConsoleColor]$MessageColor = 'DarkGray'
    [ConsoleColor]$ErrorColor = 'DarkRed'
    [ConsoleColor]$SuccessColor = 'DarkGreen'
    [ConsoleColor]$ErrorDescriptionColor = 'DarkYellow'
}

function Write-ChannelMessage{                
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message        
    )

    Write-Host "[$($Global:ChannelProps.Channel)] " -f $($Global:ChannelProps.TitleColor) -NoNewLine
    Write-Host "$Message" -f $($Global:ChannelProps.MessageColor)
}


function Write-ChannelResult{                               
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [switch]$Warning
    )

    if($Warning -eq $False){
        Write-Host "[$($Global:ChannelProps.Channel)] " -f $($Global:ChannelProps.TitleColor) -NoNewLine
        Write-Host "[ OK ] " -f $($Global:ChannelProps.SuccessColor) -NoNewLine
    }else{
        Write-Host "[WARN] " -f $($Global:ChannelProps.ErrorColor) -NoNewLine
    }
    
    Write-Host "$Message" -f $($Global:ChannelProps.MessageColor)
}



function Write-ChannelError{                              
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.ErrorRecord]$Record
    )
    $formatstring = "{0}`n{1}"
    $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
    $ExceptMsg=($formatstring -f $fields)
    Write-Host "[$($Global:ChannelProps.Channel)] " -f $($Global:ChannelProps.TitleColor) -NoNewLine
    Write-Host "[ERROR] " -f $($Global:ChannelProps.ErrorColor) -NoNewLine
    Write-Host "$ExceptMsg`n`n" -ForegroundColor DarkYellow
}
