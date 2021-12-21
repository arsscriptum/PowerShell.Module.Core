

function Remove-CommentsFromScriptBlock {

    [CmdletBinding()] 
    param(
        [String]$ScriptBlock
    )
    $IsOneLineComment = $False
    $IsComment = $False
    $Output = ""
    $NoCommentException = $False

    $Arr=$ScriptBlock.Split("`n")
    ForEach ($Line in $Arr) 
    {
        if ($Line -match "###NCX") { ###NCX
            $NoCommentException = $True
        }

        if ($Line -like "*<#*") {   ###NCX
            $IsComment = $True
        }

        if ($Line -like "#*") {     ###NCX
            $IsOneLineComment = $True
        }

        if($NoCommentException){
            $Output += "$Line`n"
        }
        elseif (-not $IsComment -And -not $IsOneLineComment) {
            $Output += "$Line`n"
        }

        $IsOneLineComment = $False

        if ($Line -like "*#>*") {   ###NCX
            $IsComment = $False
        }
    }

    return $Output
}
