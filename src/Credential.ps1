<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



function Get-CoreModuleRegistryPath { 
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModuleName = ($ExecutionContext.SessionState).Module
    $Path = "$ENV:OrganizationHKCU\$ModuleName"
   
    return $Path
}
function Get-CredentialsRegistryPath { 
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false)]
        [switch]$GlobalScope
    )  
    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModuleName = ($ExecutionContext.SessionState).Module
    $CoreModuleRegistryPath = "$ENV:OrganizationHKCU\$ModuleName"
    if($GlobalScope){
        $CoreModuleRegistryPath = "$ENV:OrganizationHKLM\$ModuleName"
    }
    $CoreModuleRegistryPath = "$ENV:OrganizationHKCU\$ModuleName"
    $Path = "$CoreModuleRegistryPath\Credentials"
   
    return $Path
}

function Show-RegisteredCredentials {
<#
    .SYNOPSIS
            Cmdlet to register new credentials in the DB

    .PARAMETER Id
            Application Id

#>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false)]
        [string]$Filter,
        [Alias("global","allusers")]
        [Parameter(Mandatory=$false)]
        [switch]$GlobalScope
    )  
    $RegKeyCredsManagerRoot = (Get-CredentialsRegistryPath -GlobalScope:$GlobalScope)
    $RegKeyRoot = "$RegKeyCredsManagerRoot\$Id\credentials"
    if($GlobalScope){
         If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
            Write-Host "GlobalScope Requires Admin privilege"
            return $false
        }
    }

    $Entries = [System.Collections.ArrayList]::new()
    $ItemProperties=Get-ItemProperty $RegKeyCredsManagerRoot
    $List = (Get-Item $RegKeyCredsManagerRoot).Property
    foreach ($id in $List){
        $UnixTime=$ItemProperties."$id"
        $epoch = [DateTime]::SpecifyKind('1970-01-01', 'Utc')
        $RegisteredDate = $epoch.AddSeconds($UnixTime)
        $c = Get-AppCredentials -Id $id -GlobalScope:$GlobalScope
        $Entry = [PSCustomObject]@{
                Id              = $id
                UnixTime        = $UnixTime
                RegisteredDate  = $RegisteredDate
                Credentials     = $c
        }
        $Entries.Add($Entry)
    }
    return $Entries
}


function Register-AppCredentials {
<#
    .SYNOPSIS
            Cmdlet to register new credentials in the DB

    .PARAMETER Id
            Application Id

#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Id,
        [Alias("global","allusers")]
        [Parameter(Mandatory=$false)]
        [switch]$GlobalScope
    )  
    $RegKeyCredsManagerRoot = (Get-CredentialsRegistryPath -GlobalScope:$GlobalScope)
    $RegKeyRoot = "$RegKeyCredsManagerRoot\$Id\credentials"
    if($GlobalScope){
         If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
            Write-Host "GlobalScope Requires Admin privilege"
            return $false
        }
        
    }

    $Credentials = Get-Credential
    $Username = $Credentials.UserName
    $Passwd=ConvertFrom-SecureString $Credentials.Password
          
    $Now = Get-Date
    $epoch = [DateTime]::SpecifyKind('1970-01-01', 'Utc')
    $epoch = [Int64]($Now.ToUniversalTime() - $epoch).TotalSeconds
    New-RegistryValue -Path $RegKeyCredsManagerRoot -Name "$Id" -Type "DWORD" -Value $epoch
    $r1=New-RegistryValue -Path $RegKeyRoot -Name "username" -Value $Username -Type "String"
    $r2=New-RegistryValue -Path $RegKeyRoot -Name "password" -Value $Passwd   -Type "String"

    return ($r1 -And $r2)
}

function Get-AppCredentials {
<#
    .SYNOPSIS
            Cmdlet to register new credentials in the DB

    .PARAMETER Id
            Application Id

#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Id,
        [Alias("global","allusers")]
        [Parameter(Mandatory=$false)]
        [switch]$GlobalScope
    )  

    $RegKeyCredsManagerRoot = (Get-CredentialsRegistryPath -GlobalScope:$GlobalScope)
    $RegKeyRoot = "$RegKeyCredsManagerRoot\$Id\credentials"
    if($GlobalScope){
         If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
            Write-Host "GlobalScope Requires Admin privilege"
            return $false
        }
        $RegKeyRoot = "$ENV:OrganizationHKLM\$Id\credentials"
        if(-not(Test-Path $RegKeyRoot)){
           return $null
        }
    }
    if(-not(Test-Path $RegKeyRoot)){
        return $null
    }
    $Username = Get-RegistryValue $RegKeyRoot "username"
    $Passwd = Get-RegistryValue $RegKeyRoot "password"
    $Password = ConvertTo-SecureString $Passwd
    $Credentials = New-Object System.Management.Automation.PSCredential $Username,$Password

    return $Credentials
}

function Get-ElevatedCredential {
<#
    .SYNOPSIS
            Cmdlet to get recorder elevated privilege
    .DESCRIPTION
            Cmdlet to get recorder elevated privilege, record it using the -Reset parameter

    .PARAMETER Reset
             Reset the elevated privilege user/password

#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false)]
        [Alias("r")]
        [switch]$Reset,
        [Alias("global","allusers")]
        [Parameter(Mandatory=$false)]
        [switch]$GlobalScope
    )  
    $AppName="DevApp"
    if($Reset.IsPresent){
        Write-Output "Setting credentials"
        $Set=Register-AppCredentials $AppName -GlobalScope:$GlobalScope
        if($Set -eq $false){
            Write-Error "Problem recording credentials"
            return $null
        }
    }
    
    $Creds=Get-AppCredentials $AppName -GlobalScope:$GlobalScope
    if($Creds -ne $null){
        return $Creds
    }
    Write-Error "No elevated credentials were registered. (use Reset param)"
    return $null
}

