<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   𝔪𝔶 𝔭𝔯𝔦𝔳𝔞𝔱𝔢 𝔭𝔬𝔴𝔢𝔯𝔰𝔥𝔢𝔩𝔩 𝔭𝔯𝔬𝔣𝔦𝔩𝔢
#̷𝓍   
#̷𝓍   ℳ𝒾𝒸𝓇ℴ𝓈ℴ𝒻𝓉.𝒫ℴ𝓌ℯ𝓇𝒮𝒽ℯ𝓁𝓁_𝓅𝓇ℴ𝒻𝒾𝓁ℯ.𝓅𝓈1 (𝗍𝗁𝗂𝗌 𝖿𝗂𝗅𝖾) 𝗌𝗁𝗈𝗎𝗅𝖽 𝗋𝖾𝗆𝖺𝗂𝗇 𝗎𝗇𝖼𝗁𝖺𝗇𝗀𝖾𝖽.
#̷𝓍   𝘌𝘥𝘪𝘵 𝘵𝘩𝘪𝘴 𝘧𝘪𝘭𝘦 𝘪𝘯𝘴𝘵𝘦𝘢𝘥 "$𝘎𝘭𝘰𝘣𝘢𝘭:𝘗𝘴𝘗𝘳𝘰𝘧𝘪𝘭𝘦𝘋𝘦𝘷𝘙𝘰𝘰𝘵\𝘗𝘳𝘰𝘧𝘪𝘭𝘦.𝘱𝘴1".
#̷𝓍   
#>


Enum AudioDeviceType
{
 Jabra = 1
 Headset = 2
}

function Select-AudioDevice{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory=$false,Position=0)]
        [ValidateSet('Jabra', 'Headset')]
        [string]$Type        
    )    
    
    $AudioDeviceId = 'USB Audio'
    switch ($Type)
    {
        "Headset" {$AudioDeviceId = 'USB Audio' } 
        "Jabra" {$AudioDeviceId = 'Jabra' } 
    }

    $Null = import-module 'AudioDeviceCmdlets' -ErrorAction Ignore -Force
    $Mod = Get-module 'AudioDeviceCmdlets'
    if($Mod -eq $Null) {throw "cannot load AudioDeviceCmdlets"}

    $PlaybackDevices = Get-AudioDevice -List | Where Type -eq 'Playback'
    $UsbDevices = $PlaybackDevices | Where Name -match $AudioDeviceId
    $UsbDevicesCount = $UsbDevices.Count
    if($UsbDevicesCount -eq 0) {throw "no usb devices"}

    $UsbDevicesIndex = ($PlaybackDevices | Where Name -match $AudioDeviceId).Index
    $UsbDevicesName = ($PlaybackDevices | Where Name -match $AudioDeviceId).Name
    Write-Host "✅ Setting Audio Device to $UsbDevicesName, index $UsbDevicesIndex"
    Set-AudioDevice -Index $UsbDevicesIndex
}

function Select-PreviousAudioDevice{
    [CmdletBinding(SupportsShouldProcess)]
    param
    ()    

    $Null = import-module 'AudioDeviceCmdlets' -ErrorAction Ignore -Force
    $Mod = Get-module 'AudioDeviceCmdlets'
    if($Mod -eq $Null) {throw "cannot load AudioDeviceCmdlets"}

    $ids = (Get-AudioDevice -List | where Type -eq 'Playback').Index
    $Min = ($ids  | measure -Minimum).Minimum
    $Max = ($ids  | measure -Maximum).Maximum
    $Current = (Get-AudioDevice -Playback).Index
    $Current--
    if($Current -lt $Min) {$Current = $Max}
    $UsbDevicesName = ($PlaybackDevices | Where Index -eq $Current).Name
    Write-Host "✅ Setting Audio Device to $UsbDevicesName, index $Current"
    Set-AudioDevice -Index $Current
}

function Select-NextAudioDevice{
    [CmdletBinding(SupportsShouldProcess)]
    param
    ()    

    $Null = import-module 'AudioDeviceCmdlets' -ErrorAction Ignore -Force
    $Mod = Get-module 'AudioDeviceCmdlets'
    if($Mod -eq $Null) {throw "cannot load AudioDeviceCmdlets"}

    $ids = (Get-AudioDevice -List | where Type -eq 'Playback').Index
    $Min = ($ids  | measure -Minimum).Minimum
    $Max = ($ids  | measure -Maximum).Maximum
    $Current = (Get-AudioDevice -Playback).Index
    $Current++
    if($Current -gt $Max) {$Current = $Min}
    $UsbDevicesName = ($PlaybackDevices | Where Index -eq $Current).Name
    Write-Host "✅ Setting Audio Device to $UsbDevicesName, index $Current"
    Set-AudioDevice -Index $Current
}

function Select-AudioExternal{
    [CmdletBinding(SupportsShouldProcess)]
    param
    ()  
    Select-AudioDevice -Type 'Jabra'
}

function Select-AudioHeadset{
    [CmdletBinding(SupportsShouldProcess)]
    param
    ()  
    Select-AudioDevice -Type 'Headset'
}
