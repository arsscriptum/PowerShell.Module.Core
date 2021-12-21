<#̷#̷\
#̷\ 
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\    
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#̷\ 
#̷##>

Function Get-IniFile ($file)       # Based on "https://stackoverflow.com/a/422529"
 {
    $ini = [ordered]@{}

    # Create a default section if none exist in the file. Like a java prop file.
    $section = "NO_SECTION"
    $ini[$section] = [ordered]@{}

    switch -regex -file $file 
    {    
        "^\[(.+)\]$" 
        {
            $section = $matches[1].Trim()
            $ini[$section] = [ordered]@{}
        }

        "^\s*(.+?)\s*=\s*(.*)" 
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value.Trim()
        }

        default
        {
            $ini[$section]["<$("{0:d4}" -f $CommentCount++)>"] = $_
        }
    }

    $ini
}

Function Set-IniFile ($iniObject, $Path, $PrintNoSection=$false, $PreserveNonData=$true)
{                                  # Based on "http://www.out-web.net/?p=109"
    $Content = @()
    ForEach ($Category in $iniObject.Keys)
    {
        if ( ($Category -notlike 'NO_SECTION') -or $PrintNoSection )
        {
            # Put a newline before category as seperator, only if there is none 
            $seperator = if ($Content[$Content.Count - 1] -eq "") {} else { "`n" }

            $Content += $seperator + "[$Category]";
        }

        ForEach ($Key in $iniObject.$Category.Keys)
        {           
            if ( $Key.StartsWith('<') )
            {
                if ($PreserveNonData)
                    {
                        $Content += $iniObject.$Category.$Key
                    }
            }
            else
            {
                $Content += "$Key = " + $iniObject.$Category.$Key
            }
        }
    }

    $Content | Set-Content $Path -Force
}


### EXAMPLE
##
## $iniObj = Get-IniFile 'c:\myfile.ini'
##
## $iniObj.existingCategory1.exisitingKey = 'value0'
## $iniObj['newCategory'] = @{
##   'newKey1' = 'value1';
##   'newKey2' = 'value2'
##   }
## $iniObj.existingCategory1.insert(0, 'keyAtFirstPlace', 'value3')
## $iniObj.remove('existingCategory2')
##
## Set-IniFile $iniObj 'c:\myNewfile.ini' -PreserveNonData $false
##


<#

[void][system.reflection.assembly]::loadfrom("nini.dll") (refer add-type now in ps2 )
$scriptDir = Split-Path -parent $MyInvocation.MyCommand.Definition
Add-Type -path $scriptDir\nini.dll

$source = New-Object Nini.Config.IniConfigSource("e:\scratch\MyApp.ini")

$fileName = $source.Configs["Logging"].Get("File Name")
$columns = $source.Configs["Logging"].GetInt("MessageColumns")
$fileSize = $source.Configs["Logging"].GetLong("MaxFileSize")

#>