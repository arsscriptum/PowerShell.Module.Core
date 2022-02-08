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
            [switch]$UseCim,
            [Parameter(Mandatory=$false)]
            [switch]$PreRelease
        )     
 
        try
        {
          $DetectedInstances = [System.Collections.ArrayList]::new()
          $vswhere = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe'
          if((Test-Path $vswhere) -And ($UseCim -eq $False)){
            Write-Verbose "use vswhere"
            $JsonData = ''
            $PreReleaseArg = ''
            if($PreRelease){
                $PreReleaseArg = "-prerelease"
            }
            $JsonData = &"$vswhere" "-legacy" "$PreReleaseArg" "-format" "json"
            $VSInstallData = @($JsonData | convertFrom-Json)
            $VsCount=$VSInstallData.Count
            Write-Verbose  "Found $VsCount VS entries"
            foreach($vse in $VSInstallData){
                $obj = [PSCustomObject]@{
                    Name = $vse.displayName
                    Description = $vse.description
                    Version = $vse.installationVersion
                    InstallDate = $vse.installDate
                    InstallationPath = $vse.installationPath
                }
                Write-Verbose "installation found: $obj"
                $null=$DetectedInstances.Add($obj)
            }
          }else{
            # use the CimInstance
            Write-Verbose "use CimInstance"
            $VSInstallData = (Get-CimInstance MSFT_VSInstance)
            $VsCount=$VSInstallData.Count
            Write-Verbose  "Found $VsCount VS entries"
            foreach($vse in $VSInstallData){
                $obj = [PSCustomObject]@{
                    Name = $vse.Name
                    Description = $vse.Description
                    Version = $vse.Version
                    InstallDate = $vse.InstallDate
                    InstallationPath = $vse.InstallLocation
                }
                Write-Verbose "installation found: $obj"
                $null=$DetectedInstances.Add($obj)
          }
         }
         return $DetectedInstances
        }
        catch
        {
            Write-Host -n -f DarkRed "[error] "
            Write-Host -f DarkYellow "$_"
        }
    }