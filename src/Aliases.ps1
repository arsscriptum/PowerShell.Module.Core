<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

#===============================================================================
# Assemblies.ps1
#===============================================================================

New-Alias -Name ra -Value Register-Assemblies -Scope Global -ErrorAction Ignore
#===============================================================================
# Date.ps1
#===============================================================================


New-Alias -Name datestr -Value Get-DateString -Scope Global -ErrorAction Ignore
New-Alias -Name ctime -Value Get-Date -Scope Global -ErrorAction Ignore
New-Alias -Name epoch -Value Get-UnixTime -Scope Global -ErrorAction Ignore


#===============================================================================
# Directory.ps1
#===============================================================================
New-Alias -Name rmd -Value Remove-DirectoryTree -Scope Global -ErrorAction Ignore
New-Alias -Name dirsize -Value Get-DirectorySize -Scope Global -ErrorAction Ignore
New-Alias -Name getdir -Value Get-DirectoryItem -Scope Global -ErrorAction Ignore
New-Alias -Name rsync -Value Sync-Directories -Scope Global -ErrorAction Ignore
New-Alias -Name dirdiff -Value Compare-Directories -Scope Global -ErrorAction Ignore
New-Alias -Name dircomp -Value Compare-Directories -Scope Global -ErrorAction Ignore
#===============================================================================
# Credential.ps1
#===============================================================================


New-Alias -Name Register-UserCredentials -Value Register-AppCredentials -Scope Global -ErrorAction Ignore
New-Alias -Name Register-CustomCredentials -Value Register-AppCredentials -Scope Global -ErrorAction Ignore
New-Alias -Name Register-Creds -Value Register-AppCredentials -Scope Global -ErrorAction Ignore
New-Alias -Name Register-ApplicationCredentials -Value Register-AppCredentials -Scope Global -ErrorAction Ignore
New-Alias -Name Get-AdminCreds -Value Get-ElevatedCredential -Scope Global -ErrorAction Ignore

#===============================================================================
# MessabeBox.ps1
#===============================================================================
New-Alias -Name msgbox -Value Show-MessageBox -Scope Global -ErrorAction Ignore

#===============================================================================
# Module.ps1
#===============================================================================
New-Alias -Name import -Value Import-CustomModule -Scope Global -ErrorAction Ignore -Description 'Import a Powershell Module very easily'
New-Alias -Name install -Value Install-ModuleToDirectory -Scope Global -ErrorAction Ignore -Description 'Install a PowerShell Module in my personal directory'

#===============================================================================
# Registry.ps1
#===============================================================================
New-Alias -Name reged -Value Start-RegistryEditor -Scope Global -ErrorAction Ignore

#===============================================================================
# Search.ps1
#===============================================================================
New-Alias -Name grep -Value Search-Pattern -Scope Global -ErrorAction Ignore
New-Alias -Name find -Value Find-Item -Scope Global -ErrorAction Ignore
New-Alias -Name search -Value Search-Item -Scope Global -ErrorAction Ignore

#===============================================================================
# Sudo.ps1
#===============================================================================
New-Alias -Name sudo -Value Invoke-ElevatedPrivilege -Scope Global -ErrorAction Ignore

#===============================================================================
# Sid.ps1
#===============================================================================
New-Alias -Name getsid -Value Get-USerSID -Scope Global -ErrorAction Ignore
New-Alias -Name sid -Value Get-SIDUSerTable -Scope Global -ErrorAction Ignore
#===============================================================================
# WebSearch.ps1
#===============================================================================
New-Alias -Name s -Value Invoke-WebSearch -Description "search the web, 's 'Star Wars' -e to search torent !" -Scope Global -ErrorAction Ignore
New-Alias -Name ws -Value Invoke-WebSearch -Description "search the web, 's 'Star Wars' -e to search torent !" -Scope Global -ErrorAction Ignore


New-Alias -Name parserepourl -value Split-RepositoryUrl


New-Alias -Name parseurl -value Split-Url