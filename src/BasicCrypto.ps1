<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Get-SystemUUID{
    try {
        $Uuid=((Get-CimInstance -Class Win32_ComputerSystemProduct).UUID)  
        return $Uuid 
    }

    catch {
        return $null
    }
}


function Check-Version{
    $VersionMajor= $PSVersionTable.PSVersion.Major
    if($VersionMajor -eq 5){
        return $true
    }
    return $false 
}


function Get-MachineCryptoGuid{
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

function Get-4KHash{
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

function Invoke-fAESDecrypt
{
    Param(
        [Parameter(Mandatory=$true)][byte[]]$aBytesToDecrypt,
        [Parameter(Mandatory=$true)][byte[]]$aPasswordBytes,
        [Parameter(Mandatory=$true)][ref]$raDecryptedBytes,
        [Parameter(Mandatory=$false)][byte[]]$aCustomSalt
    )   
    [byte[]]$oDecryptedBytes = @();
    # Salt must have at least 8 Bytes!!
    # Encrypt and decrypt must use the same salt
    [byte[]]$aSaltBytes = @(4,7,12,254,123,98,34,12,67,12,122,111) 
    if($aCustomSalt.Count -ge 1)
    {
        $aSaltBytes=$aCustomSalt
    }
    [System.IO.MemoryStream] $oMemoryStream = new-object System.IO.MemoryStream
    [System.Security.Cryptography.RijndaelManaged] $oAES = new-object System.Security.Cryptography.RijndaelManaged
    $oAES.KeySize = 256;
    $oAES.BlockSize = 128;
    [System.Security.Cryptography.Rfc2898DeriveBytes] $oKey = new-object System.Security.Cryptography.Rfc2898DeriveBytes($aPasswordBytes, $aSaltBytes, 1000);
    $oAES.Key = $oKey.GetBytes($oAES.KeySize / 8);
    $oAES.IV = $oKey.GetBytes($oAES.BlockSize / 8);
    $oAES.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $oCryptoStream = new-object System.Security.Cryptography.CryptoStream($oMemoryStream, $oAES.CreateDecryptor(), [System.Security.Cryptography.CryptoStreamMode]::Write)
    try
    {
        $oCryptoStream.Write($aBytesToDecrypt, 0, $aBytesToDecrypt.Length)
        $oCryptoStream.Close()
    }
    catch [Exception]
    {
        $raDecryptedBytes.Value=[system.text.encoding]::ASCII.GetBytes("Error occured while decoding string. Salt or Password incorrect?")
        return $false
    }
    $oDecryptedBytes = $oMemoryStream.ToArray();
    $raDecryptedBytes.Value=$oDecryptedBytes
    return $true
}

function Invoke-AESEncryption {
<#
    .SYNOPSIS
    Encryptes or Decrypts Strings or Byte-Arrays with AES
     
    .DESCRIPTION
    Takes a String or File and a Key and encrypts or decrypts it with AES256 (CBC)
     
    .PARAMETER Mode
    Encryption or Decryption Mode
     
    .PARAMETER Key
    Key used to encrypt or decrypt
     
    .PARAMETER Text
    String value to encrypt or decrypt
     
    .PARAMETER Path
    Filepath for file to encrypt or decrypt
     
    .EXAMPLE
    Invoke-AESEncryption -Mode Encrypt -Key "p@ssw0rd" -Text "Secret Text"
     
    Description
    -----------
    Encrypts the string "Secret Test" and outputs a Base64 encoded cipher text.
     
    .EXAMPLE
    Invoke-AESEncryption -Mode Decrypt -Key "p@ssw0rd" -Text "LtxcRelxrDLrDB9rBD6JrfX/czKjZ2CUJkrg++kAMfs="
     
    Description
    -----------
    Decrypts the Base64 encoded string "LtxcRelxrDLrDB9rBD6JrfX/czKjZ2CUJkrg++kAMfs=" and outputs plain text.
     
    .EXAMPLE
    Invoke-AESEncryption -Mode Encrypt -Key "p@ssw0rd" -Path file.bin
     
    Description
    -----------
    Encrypts the file "file.bin" and outputs an encrypted file "file.bin.aes"
     
    .EXAMPLE
    Invoke-AESEncryption -Mode Encrypt -Key "p@ssw0rd" -Path file.bin.aes
     
    Description
    -----------
    Decrypts the file "file.bin.aes" and outputs an encrypted file "file.bin"
#>    
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
        $aesManaged.Padding = [Security.Cryptography.PaddingMode]$Padding = 'PKCS7'
        $aesManaged.BlockSize = 128
        $aesManaged.KeySize = 128
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
                    [System.IO.File]::WriteAllBytes($outPath, $encryptedBytes)
                    (Get-Item $outPath).LastWriteTime = $File.LastWriteTime
                    return $outPath
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
                    $cipherBytes = [System.IO.File]::ReadAllBytes($File.FullName)
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
                    return $outPath
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

Function Decrypt-SecureString
{
  Param(
    [SecureString]$SecureString
  )
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
  $plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
  return $plain
}

Function New-PasswordKey 
{
  [CmdletBinding()]
  Param(
    [SecureString]$Password,

    [String]$Salt
  )
  $saltBytes = [Text.Encoding]::ASCII.GetBytes($Salt) 
  $iterations = 1000
  $keySize = 256

  $clearPass = Decrypt-SecureString -SecureString $Password
  $passwordType = 'Security.Cryptography.Rfc2898DeriveBytes'
  $passwordDerive = New-Object -TypeName $passwordType `
    -ArgumentList @( 
      $clearPass, 
      $saltBytes, 
      $iterations,
      'SHA256'
    )

  $keyBytes = $passwordDerive.GetBytes($keySize / 8)
  return $keyBytes
}

Class CipherInfo
{
  [String]$CipherText
  [Byte[]]$IV
  [String]$Salt

  CipherInfo([String]$CipherText, [Byte[]]$IV, [String]$Salt)
  {
    $this.CipherText = $CipherText
    $this.IV = $IV
    $this.Salt = $Salt
  }
}

Function Protect-AesString 
{
  [CmdletBinding()]
  Param(
    [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
    [String]$String,

    [Parameter(Position=1, Mandatory=$true)]
    [SecureString]$Password,

    [Parameter(Position=2)]
    [String]$Salt = 'qtsbp6j643ah8e0omygzwlv9u75xcfrk4j63fdane78w1zgxhucsytkirol0v25q',

    [Parameter(Position=3)]
    [Security.Cryptography.PaddingMode]$Padding = 'PKCS7'
  )
  Try 
  {
    $valueBytes = [Text.Encoding]::UTF8.GetBytes($String)
    [byte[]]$keyBytes = New-PasswordKey -Password $Password -Salt $Salt

    $cipher = [Security.Cryptography.SymmetricAlgorithm]::Create('AesManaged')
    $cipher.Mode = [Security.Cryptography.CipherMode]::CBC
    $cipher.Padding = $Padding
    $vectorBytes = $cipher.IV

    $encryptor = $cipher.CreateEncryptor($keyBytes, $vectorBytes)
    $stream = New-Object -TypeName IO.MemoryStream
    $writer = New-Object -TypeName Security.Cryptography.CryptoStream `
      -ArgumentList @(
        $stream,
        $encryptor,
        [Security.Cryptography.CryptoStreamMode]::Write
      )

    $writer.Write($valueBytes, 0, $valueBytes.Length)
    $writer.FlushFinalBlock()
    $encrypted = $stream.ToArray()

    $cipher.Clear()
    $stream.SetLength(0)
    $stream.Close()
    $writer.Clear()
    $writer.Close()
    $encryptedValue = [Convert]::ToBase64String($encrypted)
    New-Object -TypeName CipherInfo `
      -ArgumentList @($encryptedValue, $vectorBytes, $Salt)
  }
  Catch
  {
    Write-Error $_
  }
}

Function Unprotect-AesString 
{
  [CmdletBinding(DefaultParameterSetName='String')]
  Param(
    [Parameter(Position=0, Mandatory=$true, ParameterSetName='String')]
    [Alias('EncryptedString')]
    [String]$String,

    [Parameter(Position=1, Mandatory=$true)]
    [SecureString]$Password,

    [Parameter(Position=2, ParameterSetName='String')]
    [String]$Salt = 'qtsbp6j643ah8e0omygzwlv9u75xcfrk4j63fdane78w1zgxhucsytkirol0v25q',

    [Parameter(Position=3, Mandatory=$true, ParameterSetName='String')]
    [Alias('Vector')]
    [Byte[]]$InitializationVector,

    [Parameter(Position=0, Mandatory=$true, ParameterSetName='CipherInfo', ValueFromPipeline=$true)]
    [CipherInfo]$CipherInfo,

    [Parameter(Position=3, ParameterSetName='String')]
    [Parameter(Position=2, ParameterSetName='CipherInfo')]
    [Security.Cryptography.PaddingMode]$Padding = 'PKCS7'
  )
  Process
  {
    Try
    {
      if ($PSCmdlet.ParameterSetName -eq 'CipherInfo')
      {
        $Salt = $CipherInfo.Salt
        $InitializationVector = $CipherInfo.IV
        $String = $CipherInfo.CipherText
      }
      $iv = $InitializationVector

      $valueBytes = [Convert]::FromBase64String($String)
      $keyBytes = New-PasswordKey -Password $Password -Salt $Salt

      $cipher = [Security.Cryptography.SymmetricAlgorithm]::Create('AesManaged')
      $cipher.Mode = [Security.Cryptography.CipherMode]::CBC
      $cipher.Padding = $Padding

      $decryptor = $cipher.CreateDecryptor($keyBytes, $iv)
      $stream = New-Object -TypeName IO.MemoryStream `
        -ArgumentList @(, $valueBytes)
      $reader = New-Object -TypeName Security.Cryptography.CryptoStream `
        -ArgumentList @(
          $stream,
          $decryptor,
          [Security.Cryptography.CryptoStreamMode]::Read
        )

      $decrypted = New-Object -TypeName Byte[] -ArgumentList $valueBytes.Length
      $decryptedByteCount = $reader.Read($decrypted, 0, $decrypted.Length)
      $decryptedValue = [Text.Encoding]::UTF8.GetString(
        $decrypted,
        0,
        $decryptedByteCount
      )
      $cipher.Clear()
      $stream.SetLength(0)
      $stream.Close()
      $reader.Clear()
      $reader.Close()
      return $decryptedValue
    }
    Catch
    {
      Write-Error $_
    }
  }
}




Function Test-CliXmlCrypto {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    ()
    
    try{
        Clear-Host
        Write-Host "`n`n===============================================================================" -f Cyan
        Write-Host "                               Test-CliXmlCrypto                              " -f Blue;
        Write-Host "===============================================================================" -f Cyan       

        [string]$Key = 'Password_String'
   
        $FilePath = "$ENV:TEMP\cryptotest.xml"
        $FilePathCopy = "$ENV:TEMP\cryptotest_copy.xml"
        $Null = Remove-Item "$FilePath" -Force -ErrorAction "Ignore" -Recurse  

        $DataDict = @{}
        $DataDict['Username']       = 'UsernameValue'
        $DataDict['Password']       = 'PasswordValue'

        Write-Host -f DarkCyan "Export: $FilePath"
        Export-Clixml -Path $FilePath -InputObject $DataDict
        
        Write-Host -f DarkCyan "Copy: $FilePath -> $FilePathCopy"
        Copy-Item $FilePath $FilePathCopy

        $HashValue = (Get-FileHash $FilePath).Hash
        $HashCopyValue = (Get-FileHash $FilePathCopy).Hash
        Write-Host -f Red "Hash: $FilePath    `t-> $HashValue"
        Write-Host -f Red "Hash: $FilePathCopy`t-> $HashCopyValue"

        Write-Host -f Blue "Invoke-AESEncryption Encrypt: $FilePath"
        Invoke-AESEncryption -Mode 'Encrypt' -Key $Key -Path "$FilePath"
        $EncryptedFilePath = "$FilePath" + '.aes'
        
        Write-Host -f Blue "Invoke-AESEncryption Decrypt: $EncryptedFilePath"
        Invoke-AESEncryption -Mode 'Decrypt' -Key $Key -Path "$EncryptedFilePath"

        $DecryptedHashValue = (Get-FileHash $FilePath).Hash
        Write-Host -f DarkCyan "Hash original file         `t-> $HashValue"
        Write-Host -f DarkCyan "Hash orig file copy        `t-> $HashCopyValue"
        Write-Host -f DarkRed "Hash decrypted file        `t-> $DecryptedHashValue"

    }
    Catch{
        Write-Error $_
    }
}



Function Test-JsonCrypto {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    ()
    
    try{
        Clear-Host
        Write-Host "`n`n===============================================================================" -f Cyan
        Write-Host "                               Test-CliXmlCrypto                              " -f Blue;
        Write-Host "===============================================================================" -f Cyan       

        [string]$Key = 'Password_String'
   
        $FilePath = "$ENV:TEMP\cryptotest.json"
        $FilePathCopy = "$ENV:TEMP\cryptotest_copy.json"
        $Null = Remove-Item "$FilePath" -Force -ErrorAction "Ignore" -Recurse  

        $DataDict = @{}
        $DataDict['Username']       = 'UsernameValue'
        $DataDict['Password']       = 'PasswordValue'

        Write-Host -f DarkCyan "Export: $FilePath"
        $Json = ConvertTo-Json $DataDict
        Set-Content -Path $FilePath -Value $Json
        
        Write-Host -f DarkCyan "Copy: $FilePath -> $FilePathCopy"
        Copy-Item $FilePath $FilePathCopy

        $HashValue = (Get-FileHash $FilePath).Hash
        $HashCopyValue = (Get-FileHash $FilePathCopy).Hash
        Write-Host -f Red "Hash: $FilePath    `t-> $HashValue"
        Write-Host -f Red "Hash: $FilePathCopy`t-> $HashCopyValue"

        Write-Host -f Blue "Invoke-AESEncryption Encrypt: $FilePath"
        Invoke-AESEncryption -Mode 'Encrypt' -Key $Key -Path "$FilePath"
        $EncryptedFilePath = "$FilePath" + '.aes'
        
        Write-Host -f Blue "Invoke-AESEncryption Decrypt: $EncryptedFilePath"
        Invoke-AESEncryption -Mode 'Decrypt' -Key $Key -Path "$EncryptedFilePath"

        $DecryptedHashValue = (Get-FileHash $FilePath).Hash
        Write-Host -f DarkCyan "Hash original file         `t-> $HashValue"
        Write-Host -f DarkCyan "Hash orig file copy        `t-> $HashCopyValue"
        Write-Host -f DarkRed "Hash decrypted file        `t-> $DecryptedHashValue"
        Invoke-Sublime $FilePath
        Invoke-Sublime $FilePathCopy
    }
    Catch{
        Write-Error $_
    }
}



Function Test-AesCryptDecrypt {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    ()
    
    try{
        Clear-Host
        Write-Host "`n`n===============================================================================" -f Cyan
        Write-Host "                               Test-AesCryptDecrypt                                " -f Blue;
        Write-Host "===============================================================================" -f Cyan       

        $FilePath = "$ENV:TEMP\cryptotest.json"
        $Null = Remove-Item "$FilePath" -Force -ErrorAction "Ignore" -Recurse
        $Null = New-Item "$FilePath" -Force -ErrorAction "Ignore"
        $Null = Remove-Item "$FilePath" -Force -ErrorAction "Ignore"  

        $password = Read-Host -AsSecureString
        $secret = 'Super secret info...'
        Write-Host "[Test-AesCryptDecrypt] " -n -f DarkCyan ; Write-Host "Protect-AesString '$secret'" -f DarkGreen;

        $cipherInfo = Protect-AesString -String $secret -Password $password -Salt 'MoreSalt'
        $Data = $cipherInfo | ConvertTo-Json -Compress 
        Set-Content -Path "$FilePath" -Value $Data
        Write-Host "[Test-AesCryptDecrypt] " -n -f DarkCyan ; Write-Host "Save JSON '$FilePath'" -f DarkGreen;
        $info = Get-Content -Path "$FilePath" | ConvertFrom-Json
        $Result = Unprotect-AesString -String $info.CipherText -Salt $info.Salt -InitializationVector $info.IV -Password $password
        Write-Host "[Test-AesCryptDecrypt] " -n -f DarkCyan ; Write-Host "$Result" -f DarkGreen;
   
    }
    Catch{
        Write-Error $_
    }
}


function Test-AesEncryptDecrypt{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    ()
    Clear-Host
    Write-Host "`n`n===============================================================================" -f Cyan
    Write-Host "                               Test-AesEncryptDecrypt                             " -f Blue;
    Write-Host "===============================================================================" -f Cyan       

    $ClearFile="$ENV:TEMP\Clear.txt"
    $ClearFileCopy="$ENV:TEMP\ClearCopy.txt"
    $CodedFile="$ENV:TEMP\Clear.txt.aes"
    $Null = Remove-Item "$ClearFile" -Force -ErrorAction "Ignore"  
    $Null = Remove-Item "$CodedFile" -Force -ErrorAction "Ignore"  
    $DataDict = @{}
    $DataDict['Username'] = 'UsernameValue'
    $DataDict['Password'] = 'PasswordValue'

    #Export-Clixml -Path "$ClearFile" -InputObject $DataDict
    Set-Content -Path "$ClearFile" -Value (ConvertTo-Json $DataDict)

    Invoke-AESEncryption -Mode 'Encrypt' -Key 'pass' -Path "$ClearFile"
    $Null = Copy-Item "$ClearFile" "$ClearFileCopy"
    $Null = Remove-Item "$ClearFile" -Force -ErrorAction "Ignore"  

    Invoke-AESEncryption -Mode 'Decrypt' -Key 'pass' -Path "$CodedFile"

    $ClearFileHash = (Get-FileHash $ClearFileCopy).Hash
    $DecryptedFileHash = (Get-FileHash $ClearFile).Hash    
    Write-Host -f DarkYellow "Hash original  file        `t-> $ClearFileHash"
    Write-Host -f DarkRed "Hash decrypted file        `t-> $DecryptedFileHash"    

    $Sublime = 'C:\Program Files\Sublime Text 3\subl.exe'
    #&"$Sublime" $ClearFileCopy
    #&"$Sublime" $ClearFile
}

Function Test-InvokeAesFile {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    ()
    
    try{
        Clear-Host
        Write-Host "`n`n===============================================================================" -f Cyan
        Write-Host "                               Test-InvokeAesFile                                " -f Blue;
        Write-Host "===============================================================================" -f Cyan       

        $pass = Read-Host 'Enter Password' -AsSecureString
        $String = "Keep this super safe!!"
        Write-Host "[Test-UnprotectAesString] " -n -f DarkCyan ; Write-Host "Protect-AesString '$String'" -f DarkGreen;
        
        $info = Protect-AesString -String $String -Password $pass

        # Decrypt
        $ClearData = Unprotect-AesString -CipherInfo $info -Password $pass
        Write-Host "[Test-UnprotectAesString] " -n -f DarkCyan ; Write-Host "Unprotect-AesString '$ClearData'" -f DarkGreen;
   
    }
    Catch{
        Write-Error $_
    }
}

