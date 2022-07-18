
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>




function Get-CharacterList {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="The length of the character list")]
        [int]$Length,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Message")]
        [ValidateSet('numeric','lowercase','uppercase','alpha','alphanumeric')]
        [string]$Mode='alphanumeric'
    )    

    [string]$List = ""

    switch($Mode){
        'lowercase' {
            $lc=((97..122) | Get-Random -Count $Length)
            ForEach($Val in $lc){
                $List += [char]$Val
            }
        }
        'uppercase' {
            $up=((65..90) | Get-Random -Count $Length)
            ForEach($Val in $up){
                $List += [char]$Val
            }
        }
        'alpha' {
            $al=((97..122) + (65..90)| Get-Random -Count $Length)
            ForEach($Val in $al){
                $List += [char]$Val 
            }
        }         
        'alphanumeric'{
            $an=((97..122) + (48..57) + (65..90)| Get-Random -Count $Length)
            ForEach($Val in $an){
                $List += [char]$Val
            }
        }    
        'numeric' {
            $nu=((48..57)| Get-Random -Count $Length)
            ForEach($Val in $nu ){
                $List += [char]$Val
            }
        }              
    }
    
    
    return $List
}
