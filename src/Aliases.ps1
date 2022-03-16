<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
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


#===============================================================================
# Credential.ps1
#===============================================================================


New-Alias -Name Register-UserCredentials -Value Register-AppCredentials -Scope Global -ErrorAction Ignore -Force
New-Alias -Name Register-CustomCredentials -Value Register-AppCredentials -Scope Global -ErrorAction Ignore -Force
New-Alias -Name Register-Creds -Value Register-AppCredentials -Scope Global -ErrorAction Ignore -Force
New-Alias -Name Register-ApplicationCredentials -Value Register-AppCredentials -Scope Global -ErrorAction Ignore -Force
New-Alias -Name Get-AdminCreds -Value Get-ElevatedCredential -Scope Global -ErrorAction Ignore -Force

#===============================================================================
# MessabeBox.ps1
#===============================================================================
New-Alias -Name msgbox -Value Show-MessageBox -Scope Global -ErrorAction Ignore -Force

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
New-Alias -Name web -Value Invoke-StartWeb -Description "web" -Scope Global -ErrorAction Ignore  -Force

New-Alias -Name parserepourl -value Split-RepositoryUrl -Force
New-Alias -Name parseurl -value Split-Url -Force