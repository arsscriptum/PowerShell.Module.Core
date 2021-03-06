<#
#ฬท๐   ๐๐ก๐ข ๐ข๐๐ก๐๐๐ฃ๐ค๐
#ฬท๐   ๐ตโโโโโ๐ดโโโโโ๐ผโโโโโ๐ชโโโโโ๐ทโโโโโ๐ธโโโโโ๐ญโโโโโ๐ชโโโโโ๐ฑโโโโโ๐ฑโโโโโ ๐ธโโโโโ๐จโโโโโ๐ทโโโโโ๐ฎโโโโโ๐ตโโโโโ๐นโโโโโ ๐งโโโโโ๐พโโโโโ ๐ฌโโโโโ๐บโโโโโ๐ฎโโโโโ๐ฑโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐บโโโโโ๐ฒโโโโโ๐ชโโโโโ๐ตโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐ณโโโโโ๐นโโโโโ๐ชโโโโโ.๐ถโโโโโ๐จโโโโโ@๐ฌโโโโโ๐ฒโโโโโ๐ฆโโโโโ๐ฎโโโโโ๐ฑโโโโโ.๐จโโโโโ๐ดโโโโโ๐ฒโโโโโ
#>

<#
  โโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโ
  โ   Invoke-ElevatedPrivilege       
  โ   
  โ   Invoke a command with Elevated Privilege Note that this uses PowerShell Core (pwsh.exe)
  โ   to use legacy powershell, change pwsh.exe to powershell.exe
  โโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโโ
 #>
<#
    param(
        [Parameter(
            Position=0,
            ValueFromPipeline,
            ValueFromRemainingArguments)]
        [System.Object] $Object,
        #>
function Invoke-ElevatedPrivilege{

    try {

        $NumArgs = $args.Length
        if($NumArgs -eq 0){ 
            Write-Warning "No Command Specified..."
            return 
        }

        $SudoedCommand = ''
        ForEach( $word in $args)
        {
            $SudoedCommand += $word
            $SudoedCommand += ' '
        }
    $SudoedCommand += ' '

    $bytes = [System.Text.Encoding]::Unicode.GetBytes($SudoedCommand)
    $encodedCommand = [Convert]::ToBase64String($bytes)


    $PwshExe = (Get-Command "pwsh.exe").Source
    $ArgumentList = " -noprofile -noninteractive -encodedCommand $encodedCommand"

    Start-Process -FilePath $PwshExe -ArgumentList $ArgumentList -Verb RunAs

    }catch{
        [System.Management.Automation.ErrorRecord]$Record = $_
        $formatstring = "{0}`n{1}"
        $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
        $ExceptMsg=($formatstring -f $fields)
        $Stack=$Record.ScriptStackTrace
        Write-Host "[Invoke-ElevatedPrivilege] -> " -NoNewLine -ForegroundColor Red; 
        Write-Host "$ExceptMsg" -ForegroundColor Yellow
    }
}
