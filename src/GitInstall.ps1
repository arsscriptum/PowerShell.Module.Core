<#
#ฬท๐   ๐๐ก๐ข ๐ข๐๐ก๐๐๐ฃ๐ค๐
#ฬท๐   ๐ตโโโโโ๐ดโโโโโ๐ผโโโโโ๐ชโโโโโ๐ทโโโโโ๐ธโโโโโ๐ญโโโโโ๐ชโโโโโ๐ฑโโโโโ๐ฑโโโโโ ๐ธโโโโโ๐จโโโโโ๐ทโโโโโ๐ฎโโโโโ๐ตโโโโโ๐นโโโโโ ๐งโโโโโ๐พโโโโโ ๐ฌโโโโโ๐บโโโโโ๐ฎโโโโโ๐ฑโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐บโโโโโ๐ฒโโโโโ๐ชโโโโโ๐ตโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐ณโโโโโ๐นโโโโโ๐ชโโโโโ.๐ถโโโโโ๐จโโโโโ@๐ฌโโโโโ๐ฒโโโโโ๐ฆโโโโโ๐ฎโโโโโ๐ฑโโโโโ.๐จโโโโโ๐ดโโโโโ๐ฒโโโโโ
#>


function Uninstall-WindowsGit {

    [CmdletBinding(SupportsShouldProcess)]
    param
    ()

    $InstallPath='c:\Programs\Git'

    $Installed =  Test-GitInstalled
    if($Installed) {
        Write-host -f DarkRed  "Windows Git installed..."
        $LocalUninstaller = 'c:\Programs\Git\unins000.exe'
         # Args: https://jrsoftware.org/ishelp/index.php?topic=setupcmdline
        &"$LocalUninstaller"
    } 
}
  

function Install-WindowsGit {

    [CmdletBinding(SupportsShouldProcess)]
    param
    ()
    $Url='https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-64-bit.exe'
    $InstallPath='c:\Programs\Git'

    $Installed =  Test-GitInstalled
    if($Installed) {Write-host -f DarkRed  "Windows Git already installed..." ; return ; } 
    Write-host -f DarkRed  "Installing Windows Git from $Url to $InstallPath"

    $LocalInstaller = Join-Path "$ENV:Temp" "Git.exe"
    Get-OnlineFileNoCache -Url "$Url" -Path $LocalInstaller
    if(-not(Test-Path $LocalInstaller)){
        throw "Failed to get Git installer"
    }

    Write-host -f DarkRed  "$LocalInstaller /NORESTART /SUPPRESSMSGBOXES /VERYSILENT /SP /ALLUSERS /NOCANCEL /NOCLOSEAPPLICATIONS /DIR=$InstallPath"
    
    # Args: https://jrsoftware.org/ishelp/index.php?topic=setupcmdline
    &"$LocalInstaller" "/NORESTART" "/SUPPRESSMSGBOXES" "/VERYSILENT" "/SP" "/ALLUSERS" "/NOCANCEL" "/NOCLOSEAPPLICATIONS" "/DIR=`"$InstallPath`""
}



function Test-GitInstalled {
    [CmdletBinding()]
    param()

    $checkPath = 'c:\Programs\Git'

    if ($Command = Get-Command 'git.exe' -CommandType Application -ErrorAction Ignore) {
        Write-Verbose "git is on the PATH, assume it's installed"
        $true
    }
    elseif (-not (Test-Path $checkPath)) {
        Write-Verbose "Install folder doesn't exist"
        $false
    }
    elseif (-not (Get-ChildItem -Path $checkPath)) {
        Write-Verbose "Install folder exists but is empty"
        $false
    }
    else {
        Write-Verbose "Install folder exists and is not empty"

        $checkFiles = @('c:\Programs\Git\git-bash.exe', 'c:\Programs\Git\git-cmd.exe', 'c:\Programs\Git\bin\git.exe', 'c:\Programs\Git\bin\sh.exe', 'c:\Programs\Git\bin\bash.exe')
        
        ForEach($theFile in $checkFiles){
            if (-not (Test-Path $theFile)) {
                Write-Verbose "$theFile missing"
                return $false
            }
        }
        $true
    }
}
    
function Wait-GitInstalled {

    [CmdletBinding(SupportsShouldProcess)]
    param
    ()
    
    $GitInstalled = $false

    While($GitInstalled -eq $False){
        Sleep -Seconds 5
        Write-Verbose "Checking if Git is Installed....."
        $GitInstalled = Test-GitInstalled
    }

    Write-Verbose "Git is Installed"
}
