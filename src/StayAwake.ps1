

<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Set-StayAwake{
    try {

        $shell = New-Object -ComObject WScript.Shell

        $start_time = Get-Date -UFormat %s
        $current_time = $start_time
        $elapsed_time = 0

        cls
        Write-Host "Starting Compilation..."
        Write-Host "Compiling dependencies..." -n -f DarkYellow
        Start-Sleep -Seconds 1

        $count = 0

        while($true) {
          $count++
          $current_time = Get-Date -UFormat %s
          $elapsed_time = $current_time  - $start_time 
          Write-Host "." -n -f DarkYellow
          $shell.sendkeys("{NUMLOCK}{NUMLOCK}") <# Fake some input! #>
          Start-Sleep -Seconds 1.5
          $shell.sendkeys('.')
          Start-Sleep -Seconds 1.5

          if($count -gt 5){
             $count = 0
             [string]$FName = (New-Guid).Guid
             Write-Host "`n$FName" -n -f Yellow
             Write-Host " Done" -f DarkGreen
             Write-Host "Compiling dependencies..." -n -f DarkYellow

          }
        }
    }

    catch {
        return $null
    }
}


