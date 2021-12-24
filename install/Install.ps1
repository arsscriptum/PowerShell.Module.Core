<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>
[CmdletBinding(SupportsShouldProcess)]
Param
(
    [Parameter(Mandatory = $false)]
    [switch]$Alias,
    [Parameter(Mandatory = $false)]
    [switch]$Quiet    
)



function Get-PSProfileDevelopmentRoot{

    if($ENV:PSProfileDevelopmentRoot -ne $Null){
        if(Test-Path $ENV:PSProfileDevelopmentRoot -PathType Container){
            $PsProfileDevRoot = $ENV:PSProfileDevelopmentRoot
            return $PsProfileDevRoot
        }
    }else{
        $TmpPath = (Get-Item $Profile).DirectoryName
        $TmpPath = Join-Path $TmpPath 'Profile'
        if(Test-Path $TmpPath -PathType Container){
            $PsProfileDevRoot = $TmpPath
            return $PsProfileDevRoot
        }

    }
    $mydocuments = [environment]::getfolderpath("mydocuments") 
    $PsProfileDevRoot = Join-Path $mydocuments 'PowerShell\Profile'
    return $PsProfileDevRoot
}

function Get-ModuleBuilderRoot{

    if($ENV:PSModuleBuilder -ne $Null){
        if(Test-Path $ENV:PSModuleBuilder -PathType Container){
            $PsProfileDevRoot = $ENV:PSModuleBuilder
            return $ModuleBuilder
        }
    }else{
        $TmpPath = (Get-Item $Profile).DirectoryName
        $TmpPath = Join-Path $TmpPath 'Projects\PowerShell.ModuleBuilder'
        if(Test-Path $TmpPath -PathType Container){
            $ModuleBuilder = $TmpPath
            return $ModuleBuilder
        }

    }
    $mydocuments = [environment]::getfolderpath("mydocuments") 
    $ModuleBuilder = Join-Path $mydocuments 'PowerShell\Projects\PowerShell.ModuleBuilder'
    return $ModuleBuilder
}


function Get-PSModuleDevelopmentRoot{

    if($ENV:PSModuleDevelopmentRoot -ne $Null){
        if(Test-Path $ENV:PSModuleDevelopmentRoot -PathType Container){
            $PSModuleDevelopmentRoot = $ENV:PSModuleDevelopmentRoot
            return $PSModuleDevelopmentRoot
        }
    }else{
        $TmpPath = (Get-Item $Profile).DirectoryName
        $TmpPath = Join-Path $TmpPath 'Module-Development'
        if(Test-Path $TmpPath -PathType Container){
            $PSModuleDevelopmentRoot = $TmpPath
            return $PSModuleDevelopmentRoot
        }

    }
    $mydocuments = [environment]::getfolderpath("mydocuments") 
    $PSModuleDevelopmentRoot = Join-Path $mydocuments 'PowerShell\Module-Development'
    return $PSModuleDevelopmentRoot
}


$DisplayName = 'Core'
$Script:Name = 'PowerShell.Module.Core'
$RegistryPath = "$ENV:OrganizationHKCU\$Name"
Write-Host "[$DisplayName] " -f Blue -NonewLin
Write-Host " $RegistryPath" -f White

$Script:ModuleDevelopmentPath =  Get-PSModuleDevelopmentRoot
$Script:ModuleSourcePath = Join-Path $ModuleDevelopmentPath $Script:Name

Write-Host "===============================================================================" -f DarkRed
Write-Host "Module Name `t" -NoNewLine -f DarkYellow ; Write-Host "$Script:Name" -f Gray 
Write-Host "Module Path `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:ModuleSourcePath" -f Gray 
Write-Host "Devel  Path `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:ModuleDevelopmentPath" -f Gray 
Write-Host "===============================================================================" -f DarkRed   

try{
    if($Quiet -eq $False){
        Write-Host "[$DisplayName] " -f Blue -NonewLine
        Write-Host "configuring registry values" -f White
    }

    Remove-Item $RegistryPath -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
    New-Item $RegistryPath -Force  -ErrorAction SilentlyContinue | Out-Null

    New-ItemProperty $RegistryPath -Name 'SourcePath' -Value  "$Script:ModuleSourcePath"  -ErrorAction SilentlyContinue
    [Environment]::SetEnvironmentVariable('PSModCore',"$Script:ModuleSourcePath",'User')

    $PSProfileDevelopmentRoot =  Get-PSProfileDevelopmentRoot
    [Environment]::SetEnvironmentVariable('PSModDev',"$Script:ModuleDevelopmentPath",'User')
    [Environment]::SetEnvironmentVariable('PSModuleDevelopmentPath',"$Script:ModuleDevelopmentPath",'User')
    [Environment]::SetEnvironmentVariable('PSProfileDevelopmentRoot',"$PSProfileDevelopmentRoot",'User')

}catch{
    Write-Host "[error] " -f DarkRed -NonewLine
    Write-Host "$_" -f DarkYellow    
}
