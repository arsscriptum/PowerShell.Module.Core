

[CmdletBinding()]
      param(
        [Parameter(
            Position=0,
            ValueFromPipeline,
            ValueFromRemainingArguments)]
        [System.Object] $Object
    )

$i=0
$allArgs = $PsBoundParameters.Values + $args
$allArgs = $allArgs.Split(' ')
$DeleteMode = "DeletePermanently"
ForEach($path in $allArgs){
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
