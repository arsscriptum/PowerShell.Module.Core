

<#
#ฬท๐   ๐๐ก๐ข ๐ข๐๐ก๐๐๐ฃ๐ค๐
#ฬท๐   ๐ตโโโโโ๐ดโโโโโ๐ผโโโโโ๐ชโโโโโ๐ทโโโโโ๐ธโโโโโ๐ญโโโโโ๐ชโโโโโ๐ฑโโโโโ๐ฑโโโโโ ๐ธโโโโโ๐จโโโโโ๐ทโโโโโ๐ฎโโโโโ๐ตโโโโโ๐นโโโโโ ๐งโโโโโ๐พโโโโโ ๐ฌโโโโโ๐บโโโโโ๐ฎโโโโโ๐ฑโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐บโโโโโ๐ฒโโโโโ๐ชโโโโโ๐ตโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐ณโโโโโ๐นโโโโโ๐ชโโโโโ.๐ถโโโโโ๐จโโโโโ@๐ฌโโโโโ๐ฒโโโโโ๐ฆโโโโโ๐ฎโโโโโ๐ฑโโโโโ.๐จโโโโโ๐ดโโโโโ๐ฒโโโโโ
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


