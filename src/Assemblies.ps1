<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>
#Load required libraries 

$Script:WindowsAssemblyReferences = @()
$Script:WindowsAssemblyReferences += 'PresentationFramework'
$Script:WindowsAssemblyReferences += 'PresentationCore'
$Script:WindowsAssemblyReferences += 'WindowsBase'
$Script:WindowsAssemblyReferences += 'System.Windows.Forms'
$Script:WindowsAssemblyReferences += 'System.Drawing'
$Script:WindowsAssemblyReferences += 'System' 
$Script:WindowsAssemblyReferences += 'System.Xml' 
if($PsVersionTable.PsVersion.Major -eq 5){
    $Script:WindowsAssemblyReferences += 'System.Speech'
}
function Show-AssemblyReferences{
    <#
        .SYNOPSIS
            Cmdlet to list all current references in the array.
        

        .EXAMPLE
            PS C:\> Assembly-List-References
    #>
    Write-Verbose "List all current references in WindowsAssemblyReferences" -f Cyan
    $Script:WindowsAssemblyReferences | ForEach-Object {
        Write-Verbose "Assembly: " -f Cyan -NoNewLine
        Write-Verbose " [$PSItem]" -f Magenta
    }
}

function Add-AssemblyReference{
    <#
        .SYNOPSIS
            Cmdlet to add a reference in the reference array

        .PARAMETER Assembly
            A string representing the assembly to add.

        .EXAMPLE
            PS C:\> Assembly-Add-Reference 'System.Drawing'
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="Assembly name") ]
        [ValidateNotNullOrEmpty()]
        [Alias('n')]
        [string]$Assembly,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="call AddType") ]
        [Alias('i')]
        [switch]$Import
    )
    $Script:WindowsAssemblyReferences += $Assembly
    Write-ChannelMessage "$Assembly"
    if($Import){
        Add-Type -AssemblyName $Assembly
        Write-ChannelMessage "Importing AssemblyNam $Assembly"
    }

}

function New-AssemblyReferences{
    <#
        .SYNOPSIS
            Cmdlet to create a temporary assembly file (dll) with all the reference in it. Then include it in the script

        .EXAMPLE
            PS C:\>  
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Assembly name") ]
        [string]$Source,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="call AddType") ]
        [Alias('i')]
        [switch]$Import
    )    
    
    If( $PSBoundParameters.ContainsKey('Source') -eq $False ){
        $Source = @"
        using System;
        namespace MyControl
        {
        //  C# Source
        }
"@        
    }
    $AssemblyReferences = @()
    $AssemblyReferences += 'System' 
    $AssemblyReferences += 'System.Xml'     
    $NewFile = (New-TemporaryFile).Fullname
    $NewDllPath = (Get-Item $NewFile).DirectoryName
    $NewDllName = (Get-Item $NewFile).Basename + '.dll'
    $NewDll = Join-Path $NewDllPath $NewDllName
    Rename-Item $NewFile $NewDll
    $CompilerOptions = '/unsafe'
    $OutputType = 'Library'
    Write-ChannelMessage "NewDll $NewDll"
    Write-ChannelMessage "CompilerOptions $CompilerOptions"
    Write-ChannelMessage "OutputType $OutputType"
    Write-ChannelMessage "Source $Source"
    Write-ChannelMessage "Dependencies $AssemblyReferences"
    Try {
        Write-Verbose "Add-Type -TypeDefinition $Source -OutputAssembly $NewDll -CompilerOptions $CompilerOptions -ReferencedAssemblies $AssemblyReferences -OutputType $OutputType -PassThru"
        $Result = Add-Type -TypeDefinition $Source -OutputAssembly $NewDll -CompilerOptions $CompilerOptions -ReferencedAssemblies $AssemblyReferences -OutputType $OutputType -PassThru
        Add-Type -LiteralPath $NewDll -ErrorAction Stop
        Write-ChannelResult "$$Result"
        return $NewDll
    }  
    Catch {
        Write-Warning -Message "Failed to import $_"
    }    
}

function Register-Assemblies{

    #Load required libraries 
    #Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing
   
    Foreach ($Ref in $Script:WindowsAssemblyReferences) {
        Try {
            Write-Verbose "Assembly: " -f DarkRed -NoNewLine
            Write-Verbose " [$Ref]" -f DarkYellow
            Add-Type -AssemblyName $Ref
        }  
        Catch {
            Write-Warning -Message "Failed to import $Ref"
        }
    }    
}

