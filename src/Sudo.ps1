<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   Invoke-ElevatedPrivilege       
  ║   
  ║   Invoke a command with Elevated Privilege Note that this uses PowerShell Core (pwsh.exe)
  ║   to use legacy powershell, change pwsh.exe to powershell.exe
  ╙──────────────────────────────────────────────────────────────────────────────────────
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
