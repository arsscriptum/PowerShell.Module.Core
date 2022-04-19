<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Get-SystemUUID
{
    try {
        $Uuid=((Get-CimInstance -Class Win32_ComputerSystemProduct).UUID)  
        return $Uuid 
    }

    catch {
        return $null
    }
}


function Check-Version
{
    $VersionMajor= $PSVersionTable.PSVersion.Major
    if($VersionMajor -eq 5){
        return $true
    }
    return $false 
}


function Get-MachineCryptoGuid
{
    $Path="HKLM:\SOFTWARE\Microsoft\Cryptography"
    $Entry="MachineGuid"
    try {
        $Result=(Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Entry)
        return $Result
    }

    catch {
        return $null
    }
}

function Get-4KHash
{
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
        return $null
    }
    
    try {
        $4KHash=(Get-CimInstance -Namespace root/cimv2/mdm/dmmap -Class MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'").DeviceHardwareData
        return $4KHash 
    }

    catch {
        return $null
    }
}


function Test-Machine-Identification
{
    $Result=Get-4KHash
    Write-Host '[Test-Machine-Identification]' -f Red -b Yellow -NoNewLine; Write-Host "`t`t[Get-4KHash]" -f Yellow -b Magenta 
    Write-Host "$Result" -f White
    $Result=Get-MachineCryptoGuid
    Write-Host '[Test-Machine-Identification]' -f Red -b Yellow -NoNewLine; Write-Host "`t`t[Get-MachineCryptoGuid]" -f Yellow -b Magenta 
    Write-Host "$Result" -f White
    $Result=Get-SystemUUID
    Write-Host '[Test-Machine-Identification]' -f Red -b Yellow -NoNewLine; Write-Host "`t`t[Get-SystemUUID]" -f Yellow -b Magenta 
    Write-Host "$Result" -f White
}

Function Get-PossiblePasswordList{

    [CmdletBinding(SupportsShouldProcess)]
    Param
    ()

    $PasswdList = [System.Collections.ArrayList]::new()
    if(Get-SystemUUID -ne $null){
        $Key=Get-SystemUUID
        $Key = $Key -replace "-"
        $Key = $Key.SubString(0,30)
        $null=$PasswdList.Add($Key)
    }

    if(Get-MachineCryptoGuid -ne $null){
        $Key=Get-MachineCryptoGuid
        $Key = $Key -replace "-"
        $Key = $Key.SubString(0,30)
        $null=$PasswdList.Add($Key)
    }
    if(Get-4KHash -ne $null){
        $Key=Get-4KHash
        $Key = $Key -replace "-"
        $Key = $Key.SubString(0,30)
        $null=$PasswdList.Add($Key)
    }
    if($env:COMPUTERNAME -ne $null -And $env:COMPUTERNAME -ne ""){
        $Key=$env:COMPUTERNAME
        $Key = $Key -replace "-"
        $KeyLen = $Key.Length
        if($KeyLen -gt 30) { 
             $Key = $Key.SubString(0,30)
        }elseif($KeyLen -lt 16) { 
            $KeyLen = $Key.Length
            $MissingChars=30-$KeyLen
            $RandString='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
            $RandString = $RandString -replace "-"
            $RandString = $RandString.SubString(0,$MissingChars)
            $Key = $Key + $RandString
        }
        $null=$PasswdList.Add($Key)
    }

    return $PasswdList
}

function Invoke-AESEncryption {
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Encrypt', 'Decrypt')]
        [String]$Mode,

        [Parameter(Mandatory = $true)]
        [String]$Key,

        [Parameter(Mandatory = $true, ParameterSetName = "CryptText")]
        [String]$Text,

        [Parameter(Mandatory = $true, ParameterSetName = "CryptFile")]
        [String]$Path
    )

    Begin {
        $shaManaged = New-Object System.Security.Cryptography.SHA256Managed
        $aesManaged = New-Object System.Security.Cryptography.AesManaged
        $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
        $aesManaged.BlockSize = 128
        $aesManaged.KeySize = 256
    }

    Process {
        $aesManaged.Key = $shaManaged.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Key))

        switch ($Mode) {
            'Encrypt' {
                if ($Text) {$plainBytes = [System.Text.Encoding]::UTF8.GetBytes($Text)}
                
                if ($Path) {
                    $File = Get-Item -Path $Path -ErrorAction SilentlyContinue
                    if (!$File.FullName) {
                        Write-Error -Message "File not found!"
                        break
                    }
                    $plainBytes = [System.IO.File]::ReadAllBytes($File.FullName)
                    $outPath = $File.FullName + ".aes"
                }

                $encryptor = $aesManaged.CreateEncryptor()
                $encryptedBytes = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)
                $encryptedBytes = $aesManaged.IV + $encryptedBytes
                $aesManaged.Dispose()

                if ($Text) {return [System.Convert]::ToBase64String($encryptedBytes)}
                
                if ($Path) {
                    $B64Cipher=[System.Convert]::ToBase64String($encryptedBytes)
                    Set-Content -Path $outPath -Value $B64Cipher
                    #[System.IO.File]::WriteAllBytes($outPath, $encryptedBytes)
                    (Get-Item $outPath).LastWriteTime = $File.LastWriteTime
                    return "File encrypted to $outPath"
                }
            }

            'Decrypt' {
                if ($Text) {$cipherBytes = [System.Convert]::FromBase64String($Text)}
                
                if ($Path) {
                    $File = Get-Item -Path $Path -ErrorAction SilentlyContinue
                    if (!$File.FullName) {
                        Write-Error -Message "File not found!"
                        break
                    }
                    #$cipherBytes = [System.IO.File]::ReadAllBytes($File.FullName)
                    $B64Cipher = Get-Content $File.FullName
                    $cipherBytes=[System.Convert]::FromBase64String($B64Cipher)
                    $outPath = $File.FullName -replace ".aes"
                }

                $aesManaged.IV = $cipherBytes[0..15]
                $decryptor = $aesManaged.CreateDecryptor()
                $decryptedBytes = $decryptor.TransformFinalBlock($cipherBytes, 16, $cipherBytes.Length - 16)
                $aesManaged.Dispose()

                if ($Text) {return [System.Text.Encoding]::UTF8.GetString($decryptedBytes).Trim([char]0)}
                
                if ($Path) {
                    [System.IO.File]::WriteAllBytes($outPath, $decryptedBytes)
                    (Get-Item $outPath).LastWriteTime = $File.LastWriteTime
                    #return "File decrypted to $outPath"
                }
            }
        }
    }

    End {
        $shaManaged.Dispose()
        $aesManaged.Dispose()
    }
}



Function Decrypt-String {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$EncryptedString,
        [Parameter(Mandatory = $false)]
        [string]$Passphrase="",
        [Parameter(Mandatory = $false)]
        [switch]$UseSystemUUID,
        [Parameter(Mandatory = $false)]
        [switch]$UseCryptoGuid,
        [Parameter(Mandatory = $false)]
        [switch]$Use4KHash
    )
    $BackupEA = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"

    $DecryptionKey=""

    if ($PSBoundParameters.ContainsKey('Passphrase')) {
        $DecryptionKey=$Passphrase
        Write-Verbose "Using Password: $DecryptionKey"
        $Result=Invoke-AESEncryption -Mode decrypt -Key $DecryptionKey -Text $EncryptedString
        return $Result  
    }else {

        if ($PSBoundParameters.ContainsKey('UseSystemUUID')) {
            $DecryptionKey=Get-SystemUUID
            Write-Verbose "Using (rying) Password: $DecryptionKey"
            $Result=Invoke-AESEncryption -Mode decrypt -Key $DecryptionKey -Text $EncryptedString
            if($Result -ne $null){
                return $Result  
            }
        
        }elseif($PSBoundParameters.ContainsKey('UseCryptoGuid')) {
            $DecryptionKey=Get-MachineCryptoGuid
            Write-Verbose "Using (rying) Password: $DecryptionKey"
            $Result=Invoke-AESEncryption -Mode decrypt -Key $DecryptionKey -Text $EncryptedString
            if($Result -ne $null){
                return $Result  
            }
        
        }elseif($PSBoundParameters.ContainsKey('Use4KHash')) {
            $DecryptionKey=Get-4KHash
            Write-Verbose "Using (rying) Password: $DecryptionKey"
            $Result=Invoke-AESEncryption -Mode decrypt -Key $DecryptionKey -Text $EncryptedString
            if($Result -ne $null){
                return $Result  
            }
        }else{
           return $null
        }
       
    }
    Catch{
        Write-Error $_
    }
}

Function Encrypt-String {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$String,
        [Parameter(Mandatory = $false)]
        [string]$Passphrase="",
        [Parameter(Mandatory = $false)]
        [switch]$UseSystemUUID,
        [Parameter(Mandatory = $false)]
        [switch]$UseCryptoGuid,
        [Parameter(Mandatory = $false)]
        [switch]$Use4KHash
    )
    $BackupEA = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"

    Write-Verbose " ----- Encrypt-String -----"
    $DecryptionKey=""
    if ($PSBoundParameters.ContainsKey('Passphrase')) {
        $EncryptionKey=$Passphrase
        Write-Verbose "Using Password: $EncryptionKey"
        $Result=Invoke-AESEncryption -Mode encrypt -Key $EncryptionKey -Text $String
        return $Result  
    }else {
        if ($PSBoundParameters.ContainsKey('UseSystemUUID')) {
            $EncryptionKey=Get-SystemUUID
            Write-Verbose "Using (rying) Password: $EncryptionKey"
            $Result=Invoke-AESEncryption -Mode encrypt -Key $EncryptionKey -Text $String
            if($Result -ne $null){
                return $Result 
            } 
        
        }elseif($PSBoundParameters.ContainsKey('UseCryptoGuid')) {
            $EncryptionKey=Get-MachineCryptoGuid
            Write-Verbose "Using (rying) Password: $EncryptionKey"
            $Result=Invoke-AESEncryption -Mode encrypt -Key $EncryptionKey -Text $String
            if($Result -ne $null){
                return $Result  
            }
        }elseif($PSBoundParameters.ContainsKey('Use4KHash')) {
            $EncryptionKey=Get-4KHash
            Write-Verbose "Using (rying) Password: $EncryptionKey"
            $Result=Invoke-AESEncryption -Mode encrypt -Key $EncryptionKey -Text $String
            if($Result -ne $null){
                return $Result  
            }
        }else{
            return $null        
        }
    }
       
    Catch{
        Write-Error $_
    }
}

Function Test-EncryptionDecryption {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    ()
    $BackupEA = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"

    try{
        $ClearText = (New-Guid).Guid
        Write-Host "Test-Encryption: Test 1 " -f Red -NoNewLine
        $Cipher=Encrypt-String -String $ClearText -Passphrase 'testtest'
        $Decrypted=Decrypt-String -EncryptedString $Cipher -Passphrase  'testtest'
        if($ClearText -like $Decrypted){
            Write-Output "ok"
        }else {
            throw "Error"
        }
 
        Write-Host "Test-Encryption: Test UseSystemUUID " -f Red -NoNewLine
        $Cipher=Encrypt-String -String $ClearText  -UseSystemUUID
        $Decrypted=Decrypt-String -EncryptedString $Cipher  -UseSystemUUID
        if($ClearText -like $Decrypted){
            Write-Output "ok"
        }else {
            throw "Error"
        }

        Write-Host "Test-Encryption: Test UseCryptoGuid " -f Red -NoNewLine
        $Cipher=Encrypt-String -String $ClearText -UseCryptoGuid
        $Decrypted=Decrypt-String -EncryptedString $Cipher -UseCryptoGuid
        if($ClearText -like $Decrypted){
            Write-Output "ok"
        }else {
            throw "Error"
        }

        Write-Host "Test-Encryption: Test Use4KHash " -f Red -NoNewLine
        $Cipher=Encrypt-String -String $ClearText -Use4KHash
        $Decrypted=Decrypt-String -EncryptedString $Cipher -Use4KHash
        if($ClearText -like $Decrypted){
            Write-Output "ok"
        }else {
            throw "Error"
        }


   
    }
    Catch{
        Write-Error $_
    }
}
