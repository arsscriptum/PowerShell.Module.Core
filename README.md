#  ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ -- CodeCastor.PowerShell.Core


## Description

Tooling for Powershell environment. Largely built from scratch, with references from some quality developers it provides world-class support for administration, app development and general functionalities

## Installation
---------------

Whenever possible, install all modules in a path that is listed in the PSModulePath environment variable or add the module path to the PSModulePath environment variable value.

The PSModulePath environment variable ($Env:PSModulePath) contains the locations of Windows PowerShell modules. Cmdlets rely on the value of this environment variable to find modules.

To install PwshToolsSuite it is usually enough to just do Install-Module PwshToolsSuite -Force. And then follow it by
```` 
```
Import-Module CodeCastor.PowerShell.Core -PassThru. This is the output you should see in the console:

C:\> Import-Module CodeCastor.PowerShell.Core

ModuleType Version    PreRelease Name
---------- -------    ---------- ----
Script     1.0.1                 CodeCastor.PowerShell.Core

```
````

## Sub-module: Machine-Identification.ps1

The traditional method of leverage the MAC address as the computer’s unique identifier is not going to work anymore. Why? Because each computer can easily have multiple MAC addresses from multiple network adapter.

#### Product ID

That UUID is the best way to ID a machine, it exists in Windows, Mac and many other platforms. It is 32 characters in length, a universally unique identifier. You can run the above wmic command to get it.

#### HDD Serial 

The Hard drive’s serial number as a unique identifier. That’s almost the better approach if UUID fails, meaning that you can rely on the HDD’s serial number.

#### MAachine GUID

This key is generated uniquely during the installation of Windows and it won’t change regardless of any hardware swap (apart from replacing the boot-able hard drive where the OS are installed on). That means if you want to keep tracking installation per OS this is another alternative. It won’t change unless you do a fresh reinstall of Windows.

#### 4K Hash

Windows 10 system can also be identified by a so-called 4K-Hash, a special hash string that is 4000 bytes in size. It is just one piece of information required to register Windows machines yet it may be interesting by itself to uniquely identify Windows operating systems for other purposes, too.

#### Table for easy visualisation (thanks https://ozh.github.io/ascii-tables/)


          Identifier         | Preference |              Code               |             Notes             
 ----------------------------|------------|---------------------------------|------------------------------- 
  Machine UUID               |          1 | wmic csproduct get UUID         | Windows,Mac&Linux.            
  Hard drive’s serial number |          2 | wmic DISKDRIVE get SerialNumber | better approach if UUID fails 
  Crypto MachineGuid         |          3 | SOFTWARE\Microsoft\Cryptography |                               
  Windows10 4K-Hash          |          4 |                                 | Requires admin                





## Tasks List
-------------
- [ ] Install script
- [ ] Web search

