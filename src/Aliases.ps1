<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

#===============================================================================
# Assemblies.ps1
#===============================================================================

New-Alias -Name ra -Value Register-Assemblies -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# Battery.ps1
#===============================================================================
New-Alias -Name batt -Value Get-BatteryLevel -Scope Global -ErrorAction Ignore -Force
New-Alias -Name battery -Value Get-BatteryLevel -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# Date.ps1
#===============================================================================

New-Alias -Name datestr -Value Get-DateString -Scope Global -ErrorAction Ignore -Force
New-Alias -Name ctime -Value Get-Date -Scope Global -ErrorAction Ignore -Force
New-Alias -Name epoch -Value Get-UnixTime -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# Directory.ps1
#===============================================================================
New-Alias -Name rmd -Value Remove-DirectoryTree -Scope Global -ErrorAction Ignore -Force
New-Alias -Name dirsize -Value Get-DirectorySize -Scope Global -ErrorAction Ignore -Force
New-Alias -Name getdir -Value Get-DirectoryItem -Scope Global -ErrorAction Ignore -Force
New-Alias -Name rsync -Value Sync-Directories -Scope Global -ErrorAction Ignore -Force
New-Alias -Name dirdiff -Value Compare-Directories -Scope Global -ErrorAction Ignore -Force
New-Alias -Name dircomp -Value Compare-Directories -Scope Global -ErrorAction Ignore -Force
New-Alias -Name foreachdir -Value Invoke-ForEachChilds -Scope Global -ErrorAction Ignore -Force
New-Alias -Name fs -Value Get-FolderSize -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# Credential.ps1
#===============================================================================
New-Alias -Name Register-UserCredentials -Value Register-AppCredentials -Scope Global -ErrorAction Ignore -Force
New-Alias -Name Register-CustomCredentials -Value Register-AppCredentials -Scope Global -ErrorAction Ignore -Force
New-Alias -Name Register-Creds -Value Register-AppCredentials -Scope Global -ErrorAction Ignore -Force
New-Alias -Name Register-ApplicationCredentials -Value Register-AppCredentials -Scope Global -ErrorAction Ignore -Force
New-Alias -Name Get-AdminCreds -Value Get-ElevatedCredential -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# Log.ps1
#===============================================================================
New-Alias -Name log -Value Write-Log -Scope Global -ErrorAction Ignore -Force
New-Alias -Name logs -Value Write-LogSuccess -Scope Global -ErrorAction Ignore -Force
New-Alias -Name logf -Value Write-LogError -Scope Global -ErrorAction Ignore -Force
New-Alias -Name logexcept -Value Write-LogException -Scope Global -ErrorAction Ignore -Force


#===============================================================================
# MessabeBox.ps1
#===============================================================================
New-Alias -Name msgbox -Value Show-MessageBox -Scope Global -ErrorAction Ignore -Force
New-Alias -Name msgboxerr -Value Show-MessageBoxError -Scope Global -ErrorAction Ignore -Force
New-Alias -Name msgboxinf -Value Show-MessageBoxInfo -Scope Global -ErrorAction Ignore -Force
New-Alias -Name standby -Value Show-MessageBoxStandby -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# Miscellaneous.ps1
#===============================================================================
New-Alias -Name cm -Value Get-CommandSource -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# Module.ps1
#===============================================================================
New-Alias -Name import -Value Import-CustomModule -Scope Global -ErrorAction Ignore -Description 'Import a Powershell Module very easily' -Force
New-Alias -Name install -Value Install-ModuleToDirectory -Scope Global -ErrorAction Ignore -Description 'Install a PowerShell Module in my personal directory' -Force

#===============================================================================
# Registry.ps1
#===============================================================================
New-Alias -Name reged -Value Start-RegistryEditor -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# Search.ps1
#===============================================================================
New-Alias -Name grep -Value Search-Pattern -Scope Global -ErrorAction Ignore -Force
New-Alias -Name find -Value Find-Item -Scope Global -ErrorAction Ignore -Force
New-Alias -Name search -Value Search-Item -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# SelectAudioDevice.ps1
#===============================================================================
New-Alias -Name headset -Value Select-AudioHeadset -Scope Global -ErrorAction Ignore -Force
New-Alias -Name jabra -Value Select-AudioExternal -Scope Global -ErrorAction Ignore -Force
New-Alias -Name setaudio -Value Select-AudioDevice -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# Sudo.ps1
#===============================================================================
New-Alias -Name sudo -Value Invoke-ElevatedPrivilege -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# Sid.ps1
#===============================================================================
New-Alias -Name getsid -Value Get-USerSID -Scope Global -ErrorAction Ignore -Force
New-Alias -Name sid -Value Get-SIDUSerTable -Scope Global -ErrorAction Ignore -Force
#===============================================================================
# WebSearch.ps1
#===============================================================================
New-Alias -Name s -Value Invoke-WebSearch -Description "search the web, 's 'Star Wars' -e to search torent !" -Scope Global -ErrorAction Ignore  -Force
New-Alias -Name ws -Value Invoke-WebSearch -Description "search the web, 's 'Star Wars' -e to search torent !" -Scope Global -ErrorAction Ignore  -Force
New-Alias -Name call -Value Invoke-OnlineCall -Description "Call on the web" -Scope Global -ErrorAction Ignore  -Force
$p = (Get-Item $Profile).DirectoryName
$p = Join-Path $p 'web-start.txt' 
New-Alias -Name web -Value Invoke-StartWeb -Description "Open a page for each address in $p" -Scope Global -ErrorAction Ignore  -Force

New-Alias -Name parserepourl -value Split-RepositoryUrl -Force
New-Alias -Name parseurl -value Split-Url -Force


#===============================================================================
# System.ps1
#===============================================================================

New-Alias -Name dirhash -Value Get-FolderHash -Scope Global -ErrorAction Ignore -Force

New-Alias -Name isadmin -Value Get-CurrentContext -Scope Global -ErrorAction Ignore -Force
New-Alias -Name elevate -Value Invoke-ElevateContext -Scope Global -ErrorAction Ignore -Force
New-Alias -Name wifispeed -Value Get-WlanSpeed -Scope Global -ErrorAction Ignore -Force
New-Alias -Name wlanspeed -Value Get-WlanSpeed -Scope Global -ErrorAction Ignore -Force


New-Alias -Name newpasswd -Value New-Password -Scope Global -ErrorAction Ignore -Force
New-Alias -Name split -Value Split-Array -Scope Global -ErrorAction Ignore -Force

New-Alias -Name countdown -Value Start-Countdown -Scope Global -ErrorAction Ignore -Force
New-Alias -Name isnull -Value Confirm-IsNullOrEmpty -Scope Global -ErrorAction Ignore -Force
New-Alias -Name co -Value Copy-Object -Scope Global -ErrorAction Ignore -Force
New-Alias -Name split -Value Split-Array -Scope Global -ErrorAction Ignore -Force

New-Alias -Name split -Value Split-Array -Scope Global -ErrorAction Ignore -Force
New-Alias -Name count -Value Measure-Count -Scope Global -ErrorAction Ignore -Force
New-Alias -Name chrono -Value Measure-TimeTaken -Scope Global -ErrorAction Ignore -Force
New-Alias -Name islock -Value Test-FileLock -Scope Global -ErrorAction Ignore -Force


New-Alias -Name df -Value Remove-FileFolder -Scope Global -ErrorAction Ignore -Force
New-Alias -Name md5 -Value Get-MD5 -Scope Global -ErrorAction Ignore -Force
New-Alias -Name dbits -Value Get-DownloadViaBits -Scope Global -ErrorAction Ignore -Force
New-Alias -Name download -Value Get-DownloadViaBits -Scope Global -ErrorAction Ignore -Force
New-Alias -Name deleteBuffer -Value Get-DeleteBuffer -Scope Global -ErrorAction Ignore -Force
New-Alias -Name rm -Value Remove-ItemCustom -Scope Global -ErrorAction Ignore -Force
New-Alias -Name rmf -Value Remove-ItemCustom -Scope Global -ErrorAction Ignore -Force
New-Alias -Name fbytes -Value Convert-Bytes -Scope Global -ErrorAction Ignore -Force





