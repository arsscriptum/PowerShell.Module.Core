<#
#ฬท๐   ๐๐ก๐ข ๐ข๐๐ก๐๐๐ฃ๐ค๐
#ฬท๐   ๐ตโโโโโ๐ดโโโโโ๐ผโโโโโ๐ชโโโโโ๐ทโโโโโ๐ธโโโโโ๐ญโโโโโ๐ชโโโโโ๐ฑโโโโโ๐ฑโโโโโ ๐ธโโโโโ๐จโโโโโ๐ทโโโโโ๐ฎโโโโโ๐ตโโโโโ๐นโโโโโ ๐งโโโโโ๐พโโโโโ ๐ฌโโโโโ๐บโโโโโ๐ฎโโโโโ๐ฑโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐บโโโโโ๐ฒโโโโโ๐ชโโโโโ๐ตโโโโโ๐ฑโโโโโ๐ฆโโโโโ๐ณโโโโโ๐นโโโโโ๐ชโโโโโ.๐ถโโโโโ๐จโโโโโ@๐ฌโโโโโ๐ฒโโโโโ๐ฆโโโโโ๐ฎโโโโโ๐ฑโโโโโ.๐จโโโโโ๐ดโโโโโ๐ฒโโโโโ
#>


Function Send-EmailNotification {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$From,
        [Parameter(Mandatory=$true,Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$To,
        [Parameter(Mandatory=$true,Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$Password,
        [Parameter(Mandatory=$true,Position=3)]
        [ValidateNotNullOrEmpty()]
        [string]$Subject,
        [Parameter(Mandatory=$true,Position=4)]
        [ValidateNotNullOrEmpty()]
        [string]$MsgBody,
        [Parameter(Mandatory=$false,Position=5)]
        [string]$file=""
    )
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        $BackupEA = $ErrorActionPreference
        $ErrorActionPreference = "Ignore"
        $ok=$true
        if($ok)
        { 
            $message = new-object System.Net.Mail.MailMessage 
            $message.From = $From 
            $message.To.Add($To)
            $message.IsBodyHtml = $True 
            $message.Subject = $Subject 

            if($file -ne ""){
              if(Test-Path -Path $file){
                  $attachment = $file
                  $attach = new-object Net.Mail.Attachment($attachment) 
                  $message.Attachments.Add($attach)   
              }
            }
            $message.body = $MsgBody
            $SMTPServer = "smtp.gmail.com"
            $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
            $SMTPClient.EnableSsl = $true
            $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($From, $Password);
            $SMTPClient.Send($message)
        }


        $ErrorActionPreference = $BackupEA
    }
    catch{
        $Msg="Send-EmailNotification Ran into an issue: $($PSItem.ToString())"
        Write-Log $Msg
    }   
}
