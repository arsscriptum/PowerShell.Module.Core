<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding()]
      param(
        [Parameter(Position=0,ValueFromPipeline)]    [string] $Path0,
        [Parameter(Position=1,ValueFromPipeline)][string] $Path1,
        [Parameter(Position=2,ValueFromPipeline)][string] $Path2,
        [Parameter(Position=3,ValueFromPipeline)][string] $Path3,
        [Parameter(Position=4,ValueFromPipeline)][string] $Path4,
        [Parameter(Position=5,ValueFromPipeline)][string] $Path5,
        [Parameter(Position=6,ValueFromPipeline)][string] $Path6,
        [Parameter(Position=7,ValueFromPipeline)][string] $Path7,
        [Parameter(Position=8,ValueFromPipeline)][string] $Path8,
        [Parameter(Position=9,ValueFromPipeline)][string] $Path9,
        [Parameter(Position=10,ValueFromPipeline)][string] $Path10,
        [Parameter(Position=11,ValueFromPipeline)][string] $Path11
    )


Add-Type -AssemblyName Microsoft.VisualBasic

$allArgs = [System.Collections.ArrayList]::new()

if($Path0) { $Null = $allArgs.Add($Path0) }
if($Path1) { $Null = $allArgs.Add($Path1) }
if($Path2) { $Null = $allArgs.Add($Path2) }
if($Path3) { $Null = $allArgs.Add($Path3) }
if($Path4) { $Null = $allArgs.Add($Path4) }
if($Path5) { $Null = $allArgs.Add($Path5) }
if($Path6) { $Null = $allArgs.Add($Path6) }
if($Path7) { $Null = $allArgs.Add($Path7) }
if($Path8) { $Null = $allArgs.Add($Path8) }

    $DeleteMode = "DeletePermanently"
    ForEach($path in $allArgs){
        if(! $path){continue;}
        $item = Get-Item -Path $path -ErrorAction SilentlyContinue
            if ($null -eq $item) {
                Write-Error ("'{0}' not found" -f $Path)
            }
            else {
                $fullpath = $item.FullName
                
                if (Test-Path -Path $fullpath -PathType Container) {
                    If( $DeleteMode -eq "DeletePermanently" ){
                        Write-Host ("Permanently Deleting Directory '{0}'" -f $fullpath) -f DarkRed
                        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($fullpath, 'OnlyErrorDialogs', $DeleteMode)
                    }else{
                        Write-Host ("[WhatIf] Permanently Deleting Directory '{0}'" -f $fullpath) -f DarkCyan
                    }
                }
                else {
                    If( $DeleteMode -eq "DeletePermanently" ){
                        Write-Host ("Permanently Deleting '{0}'" -f $fullpath) -f DarkRed
                        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($fullpath, 'OnlyErrorDialogs', $DeleteMode)
                    }else{
                        Write-Host ("[WhatIf] Permanently Deleting '{0}'" -f $fullpath) -f DarkCyan
                    }
                }
                
            }
    }


return
