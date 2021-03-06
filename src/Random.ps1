
<#
#ฬท๐   ๐๐ก๐ข ๐ข๐๐ก๐๐๐ฃ๐ค๐
#ฬท๐   ๐ตโโโโโ๐ดโโโโโ๐ผโโโโโ๐ชโโโโโ๐ทโโโโโ๐ธโโโโโ๐ญโโโโโ๐ชโโโโโ๐ฑโโโโโ๐ฑโโโโโ ๐ธโโโโโ๐จโโโโโ๐ทโโโโโ๐ฎโโโโโ๐ตโโโโโ๐นโโโโโ ๐งโโโโโ๐พโโโโโ ๐ฌโโโโโ๐บโโโโโ๐ฎโโโโโ๐ฑโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐บโโโโโ๐ฒโโโโโ๐ชโโโโโ๐ตโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐ณโโโโโ๐นโโโโโ๐ชโโโโโ.๐ถโโโโโ๐จโโโโโ@๐ฌโโโโโ๐ฒโโโโโ๐ฆโโโโโ๐ฎโโโโโ๐ฑโโโโโ.๐จโโโโโ๐ดโโโโโ๐ฒโโโโโ
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
