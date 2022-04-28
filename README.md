# PowerShell.Module.Core

## Overview

This module implements general tooling for my Powershell environment. Largely built from scratch, with references from some quality coding resources, it provides world-class support for application development, systems administration and general functionalities.

## Compilation

You need the [PowerShell.ModuleBuilder](https://github.com/arsscriptum/PowerShell.ModuleBuilder) to compile this module.

## Documentation

View [generated documentation here](https://github.com/arsscriptum/PowerShell.Module.Core/tree/master/doc)

## Sub Modules List

------------------------------------

### __ Archive __ (2)

Backup-Profile    Get-BackupFolder                                                                      


------------------------------------

### __ Assemblies __ (4)

Add-AssemblyReference    New-AssemblyReferences  Register-Assemblies     Show-AssemblyReferences 


------------------------------------

### __ BasicCrypto __ (20)

Check-Version                  Decrypt-SecureString          Decrypt-String                Encrypt-String
Get-4KHash                     Get-MachineCryptoGuid         Get-PossiblePasswordList      Get-SystemUUID
Invoke-AESEncryption           Invoke-fAESDecrypt            New-PasswordKey               Protect-AesString
Test-AesCryptDecrypt           Test-AesEncryptDecrypt        Test-CliXmlCrypto             Test-EncryptionDecryption
Test-InvokeAesFile             Test-JsonCrypto               Test-MachineIdentification    Unprotect-AesString


------------------------------------

### __ Converter __ (3)

Convert-FromBase64CompressedScriptBlock  Convert-ToBase64CompressedScriptBlock   Convert-ToPreCompiledScript


------------------------------------

### __ CopyDirectoryTree __ (1)

Copy-DirectoryTree                                                                                   


------------------------------------

### __ Credential __ (6)

Get-AppCredentials             Get-CoreModuleRegistryPath    Get-CredentialsRegistryPath   Get-ElevatedCredential
Register-AppCredentials        Show-RegisteredCredentials                                  


------------------------------------

### __ Date __ (7)

ConvertFrom-Ctime        ConvertFrom-UnixTime    ConvertTo-CTime         ConvertTo-UnixTime      Get-DateFormat
Get-DateString           Get-UnixTime                                                            


------------------------------------

### __ Directory __ (16)

Approve-Directory              Compare-Directories           Copy-DirectoryTree            Get-DirectoryItem
Get-DirectorySize              Get-DirectoryTree             Get-FolderSize                Invoke-ForEachChilds
Invoke-IsAdministrator         New-Directory                 New-DirectoryTree             Remove-DirectoryBinaries
Remove-DirectoryTree           Resolve-UnverifiedPath        Sync-Directories              Sync-Folders


------------------------------------

### __ Email __ (1)

Send-EmailNotification                                                                           


------------------------------------

### __ Exception __ (2)

New-ErrorRecord          Show-ExceptionDetails                                                   


------------------------------------

### __ GetVSInstallPaths __ (1)

Get-VSInstallPaths                                                                                   


------------------------------------

### __ GitInstall __ (4)

Install-WindowsGit       Test-GitInstalled       Uninstall-WindowsGit    Wait-GitInstalled       


------------------------------------

### __ Ini __ (2)

Get-IniFile  Set-IniFile                                                                                     


------------------------------------

### __ InstalledSoftware __ (1)

Get-InstalledSoftware                                                                            


------------------------------------

### __ Log __ (6)

Get-LogConfig            Write-InteractiveHost   Write-Log               Write-LogError          Write-LogException
Write-LogSuccess                                                                                 


------------------------------------

### __ Memory __ (6)

Get-MemoryUsageForAllProcesses           Get-ProcessCmdLine                      Get-ProcessCmdLineById
Get-ProcessMemoryUsage                   Get-ProcessMemoryUsageDetails           Get-TopMemoryUsers


------------------------------------

### __ MessageBox __ (9)

Get-MessageBoxResult           Register-ScriptAssemblies     Show-MessageBox               Show-MessageBoxError
Show-MessageBoxException       Show-MessageBoxInfo           Show-MessageBoxStandby        Show-MessageBoxVoice
Test-Popupcolors                                                                           


------------------------------------

### __ Miscellaneous __ (29)

Approve-Verb                             Clear-FolderAndCloseHandle              Clear-TemporaryFolder
Compare-ModulePathAgainstPermission      Deploy-CustomModule                     Get-AllColors
Get-CommandSource                        Get-CoreModuleInformation               Get-FunctionSource
Get-InvocationInformation                Get-ModulesDevPath                      Get-PwshExePath
Get-RandomColor                          Get-SHA512Hash                          Get-UserModulesPath
Initialize-CoreModule                    Install-PSafe                           Invoke-CommandForEach
Invoke-FindAndReplace                    Invoke-PopupImage                       Invoke-PopupMessage
New-RandomFilename                       New-TemporaryDirectory                  Remove-FilesOlderThan
Rename-FilesInFolder                     Show-CoreFuncts                         Show-Verbs
Split-RepositoryUrl                      Split-Url                               


------------------------------------

### __ Module __ (15)

Approve-FunctionNames          Get-AliasList                 Get-AssembliesDecl            Get-DefaultModulePath
Get-ExportedAliassDecl         Get-ExportedFilesDecl         Get-ExportedFunctionsDecl     Get-FunctionList
Get-ModulePath                 Get-WritableModulePath        Import-CustomModule           Install-ModuleToDirectory
Invoke-ValidateDependencies    Select-AliasName              Select-FunctionName           


------------------------------------

### __ Net __ (10)

Enable-DnsCacheService                   Get-DnsCacheServiceStatus               Get-OnlineFileNoCache
Get-OnlineStringNoCache                  Invoke-DownloadFileWithProgress         New-HostsFileFromHashTable
Remove-DnsCache                          Replace-DnsCacheServiceDll              Resolve-IPAddress
Return-DnsCacheServiceDll                                                        


------------------------------------

### __ NewSSHKey __ (3)

Get-Elevation            Install-LinuxPackage    New-SSHKey                                      


------------------------------------

### __ NewUniqueString __ (1)

New-UniqueString                                                                                        


------------------------------------

### __ Ownership __ (4)

Get-PrivStatus       Set-Owner           Set-OwnerU          Set-OwnerUByAdmin                       


------------------------------------

### __ Parser __ (1)

Remove-CommentsFromScriptBlock                                                   


------------------------------------

### __ Power __ (1)

Get-BatteryLevel                                                                                        


------------------------------------

### __ Privileges __ (4)

Get-TokenManipulatorMembers    Invoke-AssemblyCreation       Invoke-CorePrivLoad           New-CustomAssembly


------------------------------------

### __ Process __ (1)

Invoke-Process                                                                                            


------------------------------------

### __ Registry __ (7)

Export-RegistryItem      Format-RegistryPath     Get-RegistryValue       New-RegistryValue       Set-RegistryValue
Start-RegistryEditor     Test-RegistryValue                                                      


------------------------------------

### __ ResolveHost __ (2)

Resolve-Host             Test-IsValidIPAddress                                                   


------------------------------------

### __ Script __ (1)

Get-ScriptDirectory                                                                                  


------------------------------------

### __ Search __ (6)

Find-Item         Invoke-WebSearch  New-SearchUrl    Search-Files     Search-Item      Search-Pattern   


------------------------------------

### __ Security __ (6)

Confirm-IsAdministrator        Disable-ExploitGuard          Disable-RealTimeProtection    Disable-SecurityFeatures
Disable-SmartScreen            Set-ExclusionPaths                                          


------------------------------------

### __ SelectAudioDevice __ (5)

Select-AudioDevice             Select-AudioExternal          Select-AudioHeadset           Select-NextAudioDevice
Select-PreviousAudioDevice                                                                 


------------------------------------

### __ Service __ (2)

Disable-Service          List-WriteableServices                                                  


------------------------------------

### __ Sid __ (5)

Convert-SIDtoName    Get-SIDUSerTable    Get-SIDValueForUSer Get-UserNtAccount   Get-USerSID         


------------------------------------

### __ Sudo __ (1)

Invoke-ElevatedPrivilege                                                                   


------------------------------------

### __ System __ (43)

Add-GuidToCsProj               Clear-UserVariables           Confirm-IsNullOrEmpty         Convert-Bytes
ConvertFrom-UrlEncoded         ConvertTo-DateString          ConvertTo-NZT                 ConvertTo-UrlEncoded
Copy-Object                    Disable-Accessibility         Get-AllModuleFunctions        Get-ApplicationPath
Get-CurrentContext             Get-DeleteBuffer              Get-DownloadViaBits           Get-FolderHash
Get-HttpWebResponseContent     Get-MD5                       Get-ObjectProperties          Get-RecycleBinItem
Get-RecycleBinItemDetails      Get-RecycleBinItems           Get-UserVariables             Get-WlanSpeed
Install-ChocoApp               Invoke-ElevateContext         Invoke-IsAdministrator        Measure-Count
Measure-TimeTaken              New-Password                  Remove-FileFolder             Remove-ItemCustom
Restore-RecycleBinItem         Set-Directory                 Set-EnvironmentVariable       Set-TabName
Split-Array                    Start-Countdown               Test-FileLock                 Undo-RemoveItemToRecycleBin
Uninstall-ChocoApp             Update-ChocoApp               Update-File                   


------------------------------------

### __ Tasks __ (2)

Install-SimpleTask       New-ScheduledTaskFolder                                                 


------------------------------------

### __ TestIsValidIPAddress __ (1)

Test-IsValidIPAddress                                                                            


------------------------------------

### __ Timer __ (2)

Invoke-FormatElapsedTime       Measure-TimeBlock                                           


------------------------------------

### __ web __ (7)

Get-ChromeApp        Get-ChromiumShim    Invoke-OnlineCall   Invoke-OpenWebPage  Invoke-StartWeb     Invoke-WebSearch
New-SearchUrl                                                                                        


------------------------------------

### __ WebSearch __ (2)

Invoke-WebSearch  New-SearchUrl                                                                         


------------------------------------

### __ WGetUtils __ (4)

Get-RedditAudio          Get-RedditVideo         Get-RedditVideo2        Invoke-BypassPaywall    


