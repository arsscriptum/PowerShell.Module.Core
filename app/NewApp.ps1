
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding(SupportsShouldProcess)]
param (
      [Parameter(Mandatory = $false)]
      [switch]$Compile
    )

try{
    $AppScriptPath = (Resolve-UnverifiedPath "App.ps1")
    $RootPath = (Resolve-Path "$PSScriptRoot\..").Path
    $OutPath = (Resolve-Path "$PSScriptRoot\..\out").Path
    $PSM1Path = (Resolve-Path "$PSScriptRoot\..\out\CodeCastor.PowerShell.Core.psm1").Path    

    if($Compile){

        $AppTitle = "RegEd.exe"
        $AppOrg = "SysTechnica - www.sysinternals.com"
        $AppDesc = "Launches RegEdit and Jumps to Key in Clipboard"
        $AppProduct = 
        $AppCopyRight = 'Copyright (C) 2000-2021 Guillaume Plante'
        $TradeMark = 
        $AppVersion = '1.0'
        Import-Module CodeCastor.PowerShell.PS2EXE
        $CCPs2ExeMod = Get-Module CodeCastor.PowerShell.PS2EXE
        if($CCPs2ExeMod -eq $Null){
            Import-Module PS2EXE
            $Ps2ExeMod = Get-Module PS2EXE
            if($CCPs2ExeMod -eq $Null){ throw "Module import error" ; }
        }


 

        $ClCommand = Get-Command Invoke-ps2exe
        if($ClCommand -eq $Null){ throw "No Invoke-ps2exe in scope" ; }

        Write-ChannelMessage  "====================================="
        Write-ChannelMessage  "Compile"
        Write-ChannelMessage  "====================================="

        $RootPath = (Resolve-Path "$PSScriptRoot\..").Path
        $BinPath = Join-Path $RootPath 'bin'
       
        $ScriptsPath = (Resolve-Path "$PSScriptRoot").Path
        $ImgPath = Join-Path $ScriptsPath 'img'
        $IconPath = Join-Path $ImgPath 'HPOSCheck.ico'
        $OutPath = Join-Path $BinPath 'reged.exe'
        
        Remove-Item $OutPath -Force -Recurse | Out-Null
        New-Item -Path $BinPath -ItemType Directory -Force | Out-Null
        Write-ChannelMessage  "RootPath $RootPath"
        Write-ChannelMessage  "BinPath $BinPath"
        Write-ChannelMessage  "IconPath $IconPath"
        Write-ChannelMessage  "App Path $OutPath"
    # 
        Invoke-ps2exe -inputFile $AppScriptPath -outputFile "$OutPath" -iconFile "$IconPath" -noOutput -noConsole -noError -title $AppTitle -description $AppDesc -company $AppOrg -product $AppProduct -copyright $AppCopyRight -trademark $TradeMark -version $AppVersion

        Write-ChannelResult "SUCCESS!"  
        Write-ChannelResult "$OutPath ==> $FinalAppPath"  
        Copy-Item  "$OutPath" "$ENV:ToolsRoot"
        $ExpExe = (Get-Command explorer.exe).Source
        &"$ExpExe" "$ENV:ToolsRoot"
    

    }else{

        if(-not(Test-Path $PSM1Path)){throw "PSM1 File doesnt exists!"}

        Copy-Item "$PSM1Path" "$AppScriptPath"
        $script = $PSCommandPath
        subl "$AppScriptPath"
        Write-Host "When finished editing compile with $script"    
    }    
}catch {
        Show-ExceptionDetails($_) -ShowStack
}


