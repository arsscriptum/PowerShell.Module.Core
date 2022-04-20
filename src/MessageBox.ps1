<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



#===============================================================================
# Profile VARIABLES
#===============================================================================


function Register-ScriptAssemblies{
    [CmdletBinding(SupportsShouldProcess)]
    Param()

    $WindowsAssemblyReferences = [System.Collections.ArrayList]::new()
    $WindowsAssemblyReferences += 'System' | Out-Null
    $WindowsAssemblyReferences += 'System.Drawing' | Out-Null
    $WindowsAssemblyReferences += 'System.Xml' | Out-Null

    $WindowsAssemblyReferences += 'PresentationFramework' | Out-Null
    $WindowsAssemblyReferences += 'PresentationCore'   | Out-Null
    Write-Verbose "================================================================="
    Write-Verbose "MESSAGEBOX INIT ==> Register-ScriptAssemblies "
    Write-Verbose "================================================================="

    try{
        ForEach($Ref in $WindowsAssemblyReferences){
            Write-Verbose " [Add-Type -AssemblyName]  ==>  $Ref "
            Add-Type -AssemblyName $Ref
        }   
    }catch{
        Write-Warning  "[ERRIR with Assembly]  ==>  $Ref "
    }
}

function Get-ScriptDirectory{       # NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    Param()    
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    if ($Invocation.PSScriptRoot) {
        $Invocation.PSScriptRoot
    }
    elseif ($Invocation.MyCommand.Path) {
        Split-Path $Invocation.MyCommand.Path
    } else {
        $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
    }
}


Function Get-MessageBoxResult{
    $Result = Get-Variable -Name PWSHMessageBoxOutput -ValueOnly -ErrorAction Ignore
    return $Result
}

Function Show-MessageBox{
    # Define Parameters
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        # The popup Content
        [Parameter(Mandatory=$True)]
        [Object]$Content,

        # The window title
        [Parameter(Mandatory=$false)]
        [string]$Title,

        # The buttons to add
        [Parameter(Mandatory=$false)]
        [ValidateSet('OK','OK-Cancel','Abort-Retry-Ignore','Yes-No-Cancel','Yes-No','Retry-Cancel','Cancel-TryAgain-Continue','None')]
        [array]$ButtonType = 'OK',

        # The buttons to add
        [Parameter(Mandatory=$false)]
        [array]$CustomButtons,

        # Content font size
        [Parameter(Mandatory=$false)]
        [int]$ContentFontSize = 14,

        # Title font size
        [Parameter(Mandatory=$false)]
        [int]$TitleFontSize = 14,

        # BorderThickness
        [Parameter(Mandatory=$false)]
        [int]$BorderThickness = 0,

        # CornerRadius
        [Parameter(Mandatory=$false)]
        [int]$CornerRadius = 8,

        # ShadowDepth
        [Parameter(Mandatory=$false)]
        [int]$ShadowDepth = 3,

        # BlurRadius
        [Parameter(Mandatory=$false)]
        [int]$BlurRadius = 20,

        # WindowHost
        [Parameter(Mandatory=$false)]
        [object]$WindowHost,

        # Timeout in seconds,
        [Parameter(Mandatory=$false)]
        [int]$Timeout,

        # Code for Window Loaded event,
        [Parameter(Mandatory=$false)]
        [scriptblock]$OnLoaded,

        # Code for Window Closed event,
        [Parameter(Mandatory=$false)]
        [scriptblock]$OnClosed

    )


    # Dynamically Populated parameters
    DynamicParam {
        
        # ContentBackground
        $ContentBackground = 'ContentBackground'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.ContentBackground = "White"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ContentBackground, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ContentBackground, $RuntimeParameter)
        

        # FontFamily
        $FontFamily = 'FontFamily'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute)  
        $arrSet = [System.Drawing.FontFamily]::Families.Name | Select -Skip 1 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
        $AttributeCollection.Add($ValidateSetAttribute)
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($FontFamily, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($FontFamily, $RuntimeParameter)
        $PSBoundParameters.FontFamily = "Consolas"

        # TitleFontWeight
        $TitleFontWeight = 'TitleFontWeight'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Windows.FontWeights] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.TitleFontWeight = "Normal"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($TitleFontWeight, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($TitleFontWeight, $RuntimeParameter)

        # ContentFontWeight
        $ContentFontWeight = 'ContentFontWeight'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Windows.FontWeights] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.ContentFontWeight = "Normal"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ContentFontWeight, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ContentFontWeight, $RuntimeParameter)
        

        # ContentTextForeground
        $ContentTextForeground = 'ContentTextForeground'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.ContentTextForeground = "Black"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ContentTextForeground, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ContentTextForeground, $RuntimeParameter)

        # TitleTextForeground
        $TitleTextForeground = 'TitleTextForeground'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.TitleTextForeground = "Black"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($TitleTextForeground, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($TitleTextForeground, $RuntimeParameter)

        # BorderBrush
        $BorderBrush = 'BorderBrush'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.BorderBrush = "Black"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($BorderBrush, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($BorderBrush, $RuntimeParameter)


        # TitleBackground
        $TitleBackground = 'TitleBackground'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.TitleBackground = "White"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($TitleBackground, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($TitleBackground, $RuntimeParameter)

        # ButtonTextForeground
        $ButtonTextForeground = 'ButtonTextForeground'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = [System.Drawing.Brushes] | Get-Member -Static -MemberType Property | Select -ExpandProperty Name 
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $PSBoundParameters.ButtonTextForeground = "Black"
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ButtonTextForeground, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ButtonTextForeground, $RuntimeParameter)

        # Sound
        <#$Sound = 'Sound'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $False
        #$ParameterAttribute.Position = 14
        $AttributeCollection.Add($ParameterAttribute) 
        $arrSet = (Get-ChildItem "$env:SystemDrive\Windows\Media" -Filter Windows* | Select -ExpandProperty Name).Replace('.wav','')
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        $AttributeCollection.Add($ValidateSetAttribute)
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($Sound, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($Sound, $RuntimeParameter)#>

        return $RuntimeParameterDictionary
    }

    Begin{
         Register-Assemblies
    }

    Process{

    


# Define the XAML markup
[XML]$Xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="Window" Title="" SizeToContent="WidthAndHeight" WindowStartupLocation="CenterScreen" WindowStyle="None" ResizeMode="NoResize" AllowsTransparency="True" Background="Transparent" Opacity="1">
    <Window.Resources>
        <Style TargetType="{x:Type Button}">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border>
                            <Grid Background="{TemplateBinding Background}">
                                <ContentPresenter />
                            </Grid>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    <Border x:Name="MainBorder" Margin="10" CornerRadius="$CornerRadius" BorderThickness="$BorderThickness" BorderBrush="$($PSBoundParameters.BorderBrush)" Padding="0" >
        <Border.Effect>
            <DropShadowEffect x:Name="DSE" Color="Black" Direction="270" BlurRadius="$BlurRadius" ShadowDepth="$ShadowDepth" Opacity="0.6" />
        </Border.Effect>
        <Border.Triggers>
            <EventTrigger RoutedEvent="Window.Loaded">
                <BeginStoryboard>
                    <Storyboard>
                        <DoubleAnimation Storyboard.TargetName="DSE" Storyboard.TargetProperty="ShadowDepth" From="0" To="$ShadowDepth" Duration="0:0:1" AutoReverse="False" />
                        <DoubleAnimation Storyboard.TargetName="DSE" Storyboard.TargetProperty="BlurRadius" From="0" To="$BlurRadius" Duration="0:0:1" AutoReverse="False" />
                    </Storyboard>
                </BeginStoryboard>
            </EventTrigger>
        </Border.Triggers>
        <Grid >
            <Border Name="Mask" CornerRadius="$CornerRadius" Background="$($PSBoundParameters.ContentBackground)" />
            <Grid x:Name="Grid" Background="$($PSBoundParameters.ContentBackground)">
                <Grid.OpacityMask>
                    <VisualBrush Visual="{Binding ElementName=Mask}"/>
                </Grid.OpacityMask>
                <StackPanel Name="StackPanel" >                   
                    <TextBox Name="TitleBar" IsReadOnly="True" IsHitTestVisible="False" Text="$Title" Padding="10" FontFamily="$($PSBoundParameters.FontFamily)" FontSize="$TitleFontSize" Foreground="$($PSBoundParameters.TitleTextForeground)" FontWeight="$($PSBoundParameters.TitleFontWeight)" Background="$($PSBoundParameters.TitleBackground)" HorizontalAlignment="Stretch" VerticalAlignment="Center" Width="Auto" HorizontalContentAlignment="Center" BorderThickness="0" TextWrapping="Wrap" AcceptsReturn="True" />
                    <DockPanel Name="ContentHost" Margin="0,10,0,10"  >
                    </DockPanel>
                    <DockPanel Name="ButtonHost" LastChildFill="False" HorizontalAlignment="Center" >
                    </DockPanel>
                </StackPanel>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

[XML]$ButtonXaml = @"
<Button xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Width="Auto" Height="30" FontFamily="Segui" FontSize="16" Background="Transparent" Foreground="White" BorderThickness="1" Margin="10" Padding="20,0,20,0" HorizontalAlignment="Right" Cursor="Hand"/>
"@

[XML]$ButtonTextXaml = @"
<TextBlock xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" FontFamily="$($PSBoundParameters.FontFamily)" FontSize="16" Background="Transparent" Foreground="$($PSBoundParameters.ButtonTextForeground)" Padding="20,5,20,5" HorizontalAlignment="Center" VerticalAlignment="Center"/>
"@

[XML]$ContentTextXaml = @"
<TextBlock xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" TextWrapping="WrapWithOverflow" Foreground="$($PSBoundParameters.ContentTextForeground)" DockPanel.Dock="Right" HorizontalAlignment="Center" VerticalAlignment="Center" FontFamily="$($PSBoundParameters.FontFamily)" FontSize="$ContentFontSize" FontWeight="$($PSBoundParameters.ContentFontWeight)" Height="Auto" MaxWidth="400" MinWidth="350" Padding="10">$Content</TextBlock>
"@

    
    # Load the window from XAML
    $Window = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $xaml))
    $DispatcherTimer = New-Object -TypeName System.Windows.Threading.DispatcherTimer
    # Custom  to add a button
    Function Script:Add-Button {
        Param($Content)
        $Button = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $ButtonXaml))
        $ButtonText = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $ButtonTextXaml))
        $ButtonText.Text = "$Content"
        $Button.Content = $ButtonText
        $Button.Add_MouseEnter({
            $This.Content.FontSize = "17"
        })
        $Button.Add_MouseLeave({
            $This.Content.FontSize = "16"
        })
        $Button.Add_Click({
            New-Variable -Name PWSHMessageBoxOutput -Value $($This.Content.Text) -Option ReadOnly -Scope Global -Force
            Write-Verbose "New-Variable -Name PWSHMessageBoxOutput -Value $($This.Content.Text)"
            $Window.Close()
        })
        $Window.FindName('ButtonHost').AddChild($Button)
    }

    # Add buttons
    If ($ButtonType -eq "OK")
    {
        Add-Button -Content "OK"
    }

    If ($ButtonType -eq "OK-Cancel")
    {
        Add-Button -Content "OK"
        Add-Button -Content "Cancel"
    }

    If ($ButtonType -eq "Abort-Retry-Ignore")
    {
        Add-Button -Content "Abort"
        Add-Button -Content "Retry"
        Add-Button -Content "Ignore"
    }

    If ($ButtonType -eq "Yes-No-Cancel")
    {
        Add-Button -Content "Yes"
        Add-Button -Content "No"
        Add-Button -Content "Cancel"
    }

    If ($ButtonType -eq "Yes-No")
    {
        Add-Button -Content "Yes"
        Add-Button -Content "No"
    }

    If ($ButtonType -eq "Retry-Cancel")
    {
        Add-Button -Content "Retry"
        Add-Button -Content "Cancel"
    }

    If ($ButtonType -eq "Cancel-TryAgain-Continue")
    {
        Add-Button -Content "Cancel"
        Add-Button -Content "TryAgain"
        Add-Button -Content "Continue"
    }

    If ($ButtonType -eq "None" -and $CustomButtons)
    {
        Foreach ($CustomButton in $CustomButtons)
        {
            Add-Button -Content "$CustomButton"
        }
    }

    # Remove the title bar if no title is provided
    If ($Title -eq "")
    {
        $TitleBar = $Window.FindName('TitleBar')
        $Window.FindName('StackPanel').Children.Remove($TitleBar)
    }

    # Add the Content
    If ($Content -is [String])
    {
        # Replace double quotes with single to avoid quote issues in strings
        If ($Content -match '"')
        {
            $Content = $Content.Replace('"',"'")
        }
        
        # Use a text box for a string value...
        $ContentTextBox = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $ContentTextXaml))
        $Window.FindName('ContentHost').AddChild($ContentTextBox)
    }
    Else
    {
        # ...or add a WPF element as a child
        Try
        {
            $Window.FindName('ContentHost').AddChild($Content) 
        }
        Catch
        {
            $_
        }        
    }

    # Enable window to move when dragged
    $Window.FindName('Grid').Add_MouseLeftButtonDown({
        $Window.DragMove()
    })

    # Activate the window on loading
    If ($OnLoaded)
    {
        $Window.Add_Loaded({
            $This.Activate()
            Invoke-Command $OnLoaded
        })
    }
    Else
    {
        $Window.Add_Loaded({
            $This.Activate()
        })
    }
    

    # Stop the dispatcher timer if exists
    If ($OnClosed)
    {
        $Window.Add_Closed({
            If ($DispatcherTimer -ne $null)
            {
                $DispatcherTimer.Stop()
            }
            Invoke-Command $OnClosed
        })
    }
    Else
    {
        $Window.Add_Closed({
            If ($DispatcherTimer -ne $null)
            {
                $DispatcherTimer.Stop()
            }
        })
    }
    

    # If a window host is provided assign it as the owner
    If ($WindowHost)
    {
        $Window.Owner = $WindowHost
        $Window.WindowStartupLocation = "CenterOwner"
    }

    # If a timeout value is provided, use a dispatcher timer to close the window when timeout is reached
    If ($Timeout)
    {
        $Stopwatch = New-object System.Diagnostics.Stopwatch
        $TimerCode = {
            If ($Stopwatch.Elapsed.TotalSeconds -ge $Timeout)
            {
                $Stopwatch.Stop()
                $Window.Close()
            }
        }
        
        $DispatcherTimer.Interval = [TimeSpan]::FromSeconds(1)
        $DispatcherTimer.Add_Tick($TimerCode)
        $Stopwatch.Start()
        $DispatcherTimer.Start()
    }

    <# Play a sound
    If ($($PSBoundParameters.Sound))
    {
        $SoundFile = "$env:SystemDrive\Windows\Media\$($PSBoundParameters.Sound).wav"
        $SoundPlayer = New-Object System.Media.SoundPlayer -ArgumentList $SoundFile
        $SoundPlayer.Add_LoadCompleted({
            $This.Play()
            $This.Dispose()
        })
        $SoundPlayer.LoadAsync()
    }
    #>
    # Display the window
    $null = $window.Dispatcher.InvokeAsync{$window.ShowDialog()}.Wait()

   }
    
}





function Test-Popupcolors{
    [CmdletBinding(SupportsShouldProcess)]

    $colors = @("AliceBlue","AntiqueWhite","Aqua","Aquamarine","Azure","Beige","Bisque","Black","BlanchedAlmond","Blue","BlueViolet","Brown","BurlyWood","CadetBlue","Chartreuse","Chocolate","Coral","CornflowerBlue","Cornsilk","Crimson","Cyan","DarkBlue","DarkCyan","DarkGoldenrod","DarkGray","DarkGreen","DarkKhaki","DarkMagenta","DarkOliveGreen","DarkOrange","DarkOrchid","DarkRed","DarkSalmon","DarkSeaGreen","DarkSlateBlue","DarkSlateGray","DarkTurquoise","DarkViolet","DeepPink","DeepSkyBlue","DimGray","DodgerBlue","Firebrick","FloralWhite","ForestGreen","Fuchsia","Gainsboro","GhostWhite","Gold","Goldenrod","Gray","Green","GreenYellow","Honeydew","HotPink","IndianRed","Indigo","Ivory","Khaki","Lavender","LavenderBlush","LawnGreen","LemonChiffon","LightBlue","LightCoral","LightCyan","LightGoldenrodYellow","LightGray","LightGreen","LightPink","LightSalmon","LightSeaGreen","LightSkyBlue","LightSlateGray","LightSteelBlue","LightYellow","Lime","LimeGreen","Linen","Magenta","Maroon","MediumAquamarine","MediumBlue","MediumOrchid","MediumPurple","MediumSeaGreen","MediumSlateBlue","MediumSpringGreen","MediumTurquoise","MediumVioletRed","MidnightBlue","MintCream","MistyRose","Moccasin","NavajoWhite","Navy","OldLace","Olive","OliveDrab","Orange","OrangeRed","Orchid","PaleGoldenrod","PaleGreen","PaleTurquoise","PaleVioletRed","PapayaWhip","PeachPuff","Peru","Pink","Plum","PowderBlue","Purple","Red","RosyBrown","RoyalBlue","SaddleBrown","Salmon","SandyBrown","SeaGreen","SeaShell","Sienna","Silver","SkyBlue","SlateBlue","SlateGray","Snow","SpringGreen","SteelBlue","Tan","Teal","Thistle","Tomato","Transparent","Turquoise","Violet","Wheat","White","WhiteSmoke","Yellow","YellowGreen")
    $colorscount = $colors.count

    Write-Host "$colorscount colors to test"

    Register-Assemblies


    ForEach($c in $colors){
        $Color = $c
        $FontSize = 22
        Show-MessageBox -Timeout 2 -Content "$c" -Title "$c" -TitleFontWeight "Bold" -TitleBackground "$Color" -TitleTextForeground Black -TitleFontSize $FontSize -ContentBackground "$Color" -ContentFontSize ($FontSize-10) -ButtonTextForeground 'Black' -ContentTextForeground 'White'
    }
}



function Show-MessageBoxException{
<#
    .SYNOPSIS
    Display a mesage box with colors to highlight a ERROR message
    .DESCRIPTION
    Display a mesage box with colors to highlight a WARNING message
    .PARAMETER Text
    String to display
#>
 [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, Position = 0)][string]$ErrorString,
        [Parameter(Mandatory = $False, Position = 1)][System.Management.Automation.RuntimeException]$Except
    )


    $ExcptMsg = $ErrorString
    if($Except -ne $null){
        $ExcptMsg = $Except.Message
        while ($Except.InnerException) {
          $e = $Except.InnerException
          $ExcptMsg += "`n" + $Except.Message
        }        
    }

    # Create a text box
    $TextBox = New-Object System.Windows.Controls.TextBox
    $TextBox.Text = $ErrorString
    $TextBox.Padding = 5
    $TextBox.Margin = 5
    $TextBox.BorderThickness = 1
    $TextBox.FontSize = 20
    $TextBox.FontWeight = "UltraBold"
    $TextBox.Width = "NaN"
    $TextBox.IsReadOnly = $True
         
    # Create an exander
    $Expander = New-Object System.Windows.Controls.Expander
    $Expander.Header = "Error details"
    $Expander.FontSize = 14
    $Expander.Padding = 5
    $Expander.Margin = "5,5,5,0"
         
    # Bind the expander width to the text box width, so the message box width does not change when expanded
    $Binding = New-Object System.Windows.Data.Binding
    $Binding.Path = [System.Windows.Controls.TextBox]::ActualWidthProperty
    $Binding.Mode = [System.Windows.Data.BindingMode]::OneWay
    $Binding.Source = $TextBox
    [void]$Expander.SetBinding([System.Windows.Controls.Expander]::WidthProperty,$Binding)
         
    # Create a textbox for the expander
    $ExpanderTextBox = New-Object System.Windows.Controls.TextBox
    $ExpanderTextBox.Text = $ExcptMsg
    $ExpanderTextBox.Padding = 5
    $ExpanderTextBox.BorderThickness = 0
    $ExpanderTextBox.FontSize = 16
    $ExpanderTextBox.TextWrapping = "Wrap"
    $ExpanderTextBox.IsReadOnly = $True
    $Expander.Content = $ExpanderTextBox
         
    # Assemble controls into a stackpanel
    $StackPanel = New-Object System.Windows.Controls.StackPanel
    $StackPanel.AddChild($TextBox)
    $StackPanel.AddChild($Expander)
   
    
    Show-MessageBox -Content $StackPanel -Title "Powershell Exception Error" -TitleBackground Red -TitleFontSize 22 -TitleFontWeight UltraBold -Sound 'Windows Unlock' -CornerRadius 0 -TitleTextForeground Yellow
            
}



function Show-MessageBoxVoice{
<#
    .SYNOPSIS
    Display a mesage box with colors to highlight a ERROR message
    .DESCRIPTION
    Display a mesage box with colors to highlight a WARNING message
    .PARAMETER Text
    String to display
#>
 [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()]$Text
    )
        $Content = $Text
       
        $Code = {
            $Synth=Get-Global-Synthesizer
             $Synth.SelectVoice('Microsoft Zira Desktop')
             $Synth.SpeakAsync($Text) | Out-null
            }
         
        $Params = @{
            Content = "$Content"
            Title = "Error"
            ContentBackground = "WhiteSmoke"
            FontFamily = "Tahoma"
            TitleFontWeight = "Heavy"
            TitleBackground = "Red"
            TitleTextForeground = "Yellow"
            Sound = 'Windows Message Nudge'
            ButtonType = 'Cancel-TryAgain-Continue'
            OnLoaded = $Code
        }
         
        Show-MessageBox @Params
}


function Show-MessageBoxError{
<#
    .SYNOPSIS
    Display a mesage box with colors to highlight a ERROR message
    .DESCRIPTION
    Display a mesage box with colors to highlight a WARNING message
    .PARAMETER Text
    String to display
#>
 [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()]$Text
        
    )
   
    $ErrorMsgParams = @{
        Title = "Error"
        TitleBackground = "Red"
        TitleTextForeground = "Yellow"
        TitleFontWeight = "UltraBold"
        TitleFontSize = 20
    }

    Show-MessageBox @ErrorMsgParams -Content $Text
}



function Show-MessageBoxInfo{
<#
    .SYNOPSIS
    Display a mesage box with colors to highlight a ERROR message
    .DESCRIPTION
    Display a mesage box with colors to highlight a WARNING message
    .PARAMETER Text
    String to display
#>
 [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()]$Text,
        [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $True)][AllowEmptyString()]$Title='Info'
        
    )
   
    $MsgParams = @{
        Title = $Title
        TitleBackground = "Blue"
        TitleTextForeground = "Black"
        TitleFontWeight = "Bold"
        TitleFontSize = 20
    }

    Show-MessageBox @MsgParams -Content $Text
}


function Show-MessageBoxStandby{
<#
    .SYNOPSIS
    Display a mesage box
    .DESCRIPTION
    Display a mesage box
    .PARAMETER Text
    String to display
#>
 [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()]$Title='STAND BY'
        
    )
    $SourceUrl = "https://onebeatblog.files.wordpress.com/2013/04/hiatus.jpg"
    $SourceLocal = "$ENV:MyPictures\standby.jpg"
    if(-not(Test-Path $SourceLocal)){
        Get-OnlineFileNoCache -Url $SourceUrl -Path $SourceLocal
    }
    [int]$FontSize = 16
    [string]$Color='Red'
    $Image = New-Object System.Windows.Controls.Image
    $Image.Source = $SourceLocal
    $Image.Height = [System.Drawing.Image]::FromFile($SourceLocal).Height 
    $Image.Width = [System.Drawing.Image]::FromFile($SourceLocal).Width 
                 
    Show-MessageBox -Content $Image -Title "$Title" -TitleFontWeight "Bold" -TitleBackground "$Color" -TitleTextForeground Black -TitleFontSize $FontSize -ContentBackground "$Color" -ContentFontSize ($FontSize-10) -ButtonTextForeground 'Black' -ContentTextForeground 'White'        
    

}

