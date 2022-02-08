<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   Get-VSInstallPaths          
  ║   
  ║   Get Visual Studio Install Paths, using vswhere, or if not present, the registry
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>


function Get-VSInstallPaths{  
   [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$false)]
        [switch]$PreRelease
    )     
 
  try{
      $DetectedInstallataionPaths = [System.Collections.ArrayList]::new()
      $vswhere = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe'
      if(Test-Path $vswhere){
         Write-Verbose "use vswhere"
         $JsonData = ''
         if($PreRelease){
            $JsonData = &"$vswhere" "-legacy" "-prerelease" "-format" "json"
         }else{
            $JsonData = &"$vswhere" "-legacy" "-format" "json"
         }
         $JsonData = &"$vswhere" "-legacy" "-prerelease" "-format" "json"
         $InstallPaths = @($JsonData | convertFrom-Json).installationPath
         $count=$InstallPaths.Count
         Write-Verbose  "Found $count VS entries"
         foreach($vse in $InstallPaths){
            Write-Verbose "installation found:"
            Write-Verbose "$vse"
            $null=$DetectedInstallataionPaths.Add($vse)
         }
      }else{
       # use the CimInstance
       Write-Verbose "use CimInstance"
       $VSLocations = (Get-CimInstance MSFT_VSInstance).InstallLocation
       foreach($VSLocation in $VSLocations){
          $null=$DetectedInstallataionPaths.Add($VSLocation)
          Write-Verbose "installation found $VSLocation"
       }
      }
      return $DetectedInstallataionPaths
  }catch{
   Write-Host -n -f DarkRed "[error] "
   Write-Host -f DarkYellow "$_"
   return
  }
}