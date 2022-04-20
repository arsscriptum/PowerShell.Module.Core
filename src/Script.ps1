<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

function Get-ScriptDirectory
{
<#
	.SYNOPSIS
		Get-ScriptDirectory returns the proper location of the script.

	.OUTPUTS
		System.String
#>
	[OutputType([string])]
	param ()

    Try{
        if($script:MyInvocation -ne $null){
            return  Split-Path $script:MyInvocation.MyCommand.Path
        }elseif($PSScriptRoot -ne $null){
            return $PSScriptRoot
        }elseif($PSCommandPath -ne $null){
            return Split-Path $PSCommandPath
        }
        throw "Unknown Error"
    }catch [Exception]{
        Write-Host '[ERROR] ' -f DarkRed -NoNewLine
        Write-Host "Get-ScriptDirectory $_" -f DarkYellow
    }

}