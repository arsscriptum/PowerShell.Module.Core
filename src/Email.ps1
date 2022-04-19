<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
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
