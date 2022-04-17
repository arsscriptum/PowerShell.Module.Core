---
external help file: PowerShell.Module.Core-help.xml
Module Name: PowerShell.Module.Core
online version:
schema: 2.0.0
---

# Show-MessageBox

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Show-MessageBox [-Content] <Object> [[-Title] <String>] [[-ButtonType] <Array>] [[-CustomButtons] <Array>]
 [[-ContentFontSize] <Int32>] [[-TitleFontSize] <Int32>] [[-BorderThickness] <Int32>] [[-CornerRadius] <Int32>]
 [[-ShadowDepth] <Int32>] [[-BlurRadius] <Int32>] [[-WindowHost] <Object>] [[-Timeout] <Int32>]
 [[-OnLoaded] <ScriptBlock>] [[-OnClosed] <ScriptBlock>] [-WhatIf] [-Confirm] [-ContentBackground <String>]
 [-FontFamily <String>] [-TitleFontWeight <String>] [-ContentFontWeight <String>]
 [-ContentTextForeground <String>] [-TitleTextForeground <String>] [-BorderBrush <String>]
 [-TitleBackground <String>] [-ButtonTextForeground <String>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -BlurRadius
{{ Fill BlurRadius Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BorderBrush
{{ Fill BorderBrush Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AliceBlue, AntiqueWhite, Aqua, Aquamarine, Azure, Beige, Bisque, Black, BlanchedAlmond, Blue, BlueViolet, Brown, BurlyWood, CadetBlue, Chartreuse, Chocolate, Coral, CornflowerBlue, Cornsilk, Crimson, Cyan, DarkBlue, DarkCyan, DarkGoldenrod, DarkGray, DarkGreen, DarkKhaki, DarkMagenta, DarkOliveGreen, DarkOrange, DarkOrchid, DarkRed, DarkSalmon, DarkSeaGreen, DarkSlateBlue, DarkSlateGray, DarkTurquoise, DarkViolet, DeepPink, DeepSkyBlue, DimGray, DodgerBlue, Firebrick, FloralWhite, ForestGreen, Fuchsia, Gainsboro, GhostWhite, Gold, Goldenrod, Gray, Green, GreenYellow, Honeydew, HotPink, IndianRed, Indigo, Ivory, Khaki, Lavender, LavenderBlush, LawnGreen, LemonChiffon, LightBlue, LightCoral, LightCyan, LightGoldenrodYellow, LightGray, LightGreen, LightPink, LightSalmon, LightSeaGreen, LightSkyBlue, LightSlateGray, LightSteelBlue, LightYellow, Lime, LimeGreen, Linen, Magenta, Maroon, MediumAquamarine, MediumBlue, MediumOrchid, MediumPurple, MediumSeaGreen, MediumSlateBlue, MediumSpringGreen, MediumTurquoise, MediumVioletRed, MidnightBlue, MintCream, MistyRose, Moccasin, NavajoWhite, Navy, OldLace, Olive, OliveDrab, Orange, OrangeRed, Orchid, PaleGoldenrod, PaleGreen, PaleTurquoise, PaleVioletRed, PapayaWhip, PeachPuff, Peru, Pink, Plum, PowderBlue, Purple, Red, RosyBrown, RoyalBlue, SaddleBrown, Salmon, SandyBrown, SeaGreen, SeaShell, Sienna, Silver, SkyBlue, SlateBlue, SlateGray, Snow, SpringGreen, SteelBlue, Tan, Teal, Thistle, Tomato, Transparent, Turquoise, Violet, Wheat, White, WhiteSmoke, Yellow, YellowGreen

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BorderThickness
{{ Fill BorderThickness Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ButtonTextForeground
{{ Fill ButtonTextForeground Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AliceBlue, AntiqueWhite, Aqua, Aquamarine, Azure, Beige, Bisque, Black, BlanchedAlmond, Blue, BlueViolet, Brown, BurlyWood, CadetBlue, Chartreuse, Chocolate, Coral, CornflowerBlue, Cornsilk, Crimson, Cyan, DarkBlue, DarkCyan, DarkGoldenrod, DarkGray, DarkGreen, DarkKhaki, DarkMagenta, DarkOliveGreen, DarkOrange, DarkOrchid, DarkRed, DarkSalmon, DarkSeaGreen, DarkSlateBlue, DarkSlateGray, DarkTurquoise, DarkViolet, DeepPink, DeepSkyBlue, DimGray, DodgerBlue, Firebrick, FloralWhite, ForestGreen, Fuchsia, Gainsboro, GhostWhite, Gold, Goldenrod, Gray, Green, GreenYellow, Honeydew, HotPink, IndianRed, Indigo, Ivory, Khaki, Lavender, LavenderBlush, LawnGreen, LemonChiffon, LightBlue, LightCoral, LightCyan, LightGoldenrodYellow, LightGray, LightGreen, LightPink, LightSalmon, LightSeaGreen, LightSkyBlue, LightSlateGray, LightSteelBlue, LightYellow, Lime, LimeGreen, Linen, Magenta, Maroon, MediumAquamarine, MediumBlue, MediumOrchid, MediumPurple, MediumSeaGreen, MediumSlateBlue, MediumSpringGreen, MediumTurquoise, MediumVioletRed, MidnightBlue, MintCream, MistyRose, Moccasin, NavajoWhite, Navy, OldLace, Olive, OliveDrab, Orange, OrangeRed, Orchid, PaleGoldenrod, PaleGreen, PaleTurquoise, PaleVioletRed, PapayaWhip, PeachPuff, Peru, Pink, Plum, PowderBlue, Purple, Red, RosyBrown, RoyalBlue, SaddleBrown, Salmon, SandyBrown, SeaGreen, SeaShell, Sienna, Silver, SkyBlue, SlateBlue, SlateGray, Snow, SpringGreen, SteelBlue, Tan, Teal, Thistle, Tomato, Transparent, Turquoise, Violet, Wheat, White, WhiteSmoke, Yellow, YellowGreen

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ButtonType
{{ Fill ButtonType Description }}

```yaml
Type: Array
Parameter Sets: (All)
Aliases:
Accepted values: OK, OK-Cancel, Abort-Retry-Ignore, Yes-No-Cancel, Yes-No, Retry-Cancel, Cancel-TryAgain-Continue, None

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Content
{{ Fill Content Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ContentBackground
{{ Fill ContentBackground Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AliceBlue, AntiqueWhite, Aqua, Aquamarine, Azure, Beige, Bisque, Black, BlanchedAlmond, Blue, BlueViolet, Brown, BurlyWood, CadetBlue, Chartreuse, Chocolate, Coral, CornflowerBlue, Cornsilk, Crimson, Cyan, DarkBlue, DarkCyan, DarkGoldenrod, DarkGray, DarkGreen, DarkKhaki, DarkMagenta, DarkOliveGreen, DarkOrange, DarkOrchid, DarkRed, DarkSalmon, DarkSeaGreen, DarkSlateBlue, DarkSlateGray, DarkTurquoise, DarkViolet, DeepPink, DeepSkyBlue, DimGray, DodgerBlue, Firebrick, FloralWhite, ForestGreen, Fuchsia, Gainsboro, GhostWhite, Gold, Goldenrod, Gray, Green, GreenYellow, Honeydew, HotPink, IndianRed, Indigo, Ivory, Khaki, Lavender, LavenderBlush, LawnGreen, LemonChiffon, LightBlue, LightCoral, LightCyan, LightGoldenrodYellow, LightGray, LightGreen, LightPink, LightSalmon, LightSeaGreen, LightSkyBlue, LightSlateGray, LightSteelBlue, LightYellow, Lime, LimeGreen, Linen, Magenta, Maroon, MediumAquamarine, MediumBlue, MediumOrchid, MediumPurple, MediumSeaGreen, MediumSlateBlue, MediumSpringGreen, MediumTurquoise, MediumVioletRed, MidnightBlue, MintCream, MistyRose, Moccasin, NavajoWhite, Navy, OldLace, Olive, OliveDrab, Orange, OrangeRed, Orchid, PaleGoldenrod, PaleGreen, PaleTurquoise, PaleVioletRed, PapayaWhip, PeachPuff, Peru, Pink, Plum, PowderBlue, Purple, Red, RosyBrown, RoyalBlue, SaddleBrown, Salmon, SandyBrown, SeaGreen, SeaShell, Sienna, Silver, SkyBlue, SlateBlue, SlateGray, Snow, SpringGreen, SteelBlue, Tan, Teal, Thistle, Tomato, Transparent, Turquoise, Violet, Wheat, White, WhiteSmoke, Yellow, YellowGreen

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ContentFontSize
{{ Fill ContentFontSize Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ContentFontWeight
{{ Fill ContentFontWeight Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Black, Bold, DemiBold, ExtraBlack, ExtraBold, ExtraLight, Heavy, Light, Medium, Normal, Regular, SemiBold, Thin, UltraBlack, UltraBold, UltraLight

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ContentTextForeground
{{ Fill ContentTextForeground Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AliceBlue, AntiqueWhite, Aqua, Aquamarine, Azure, Beige, Bisque, Black, BlanchedAlmond, Blue, BlueViolet, Brown, BurlyWood, CadetBlue, Chartreuse, Chocolate, Coral, CornflowerBlue, Cornsilk, Crimson, Cyan, DarkBlue, DarkCyan, DarkGoldenrod, DarkGray, DarkGreen, DarkKhaki, DarkMagenta, DarkOliveGreen, DarkOrange, DarkOrchid, DarkRed, DarkSalmon, DarkSeaGreen, DarkSlateBlue, DarkSlateGray, DarkTurquoise, DarkViolet, DeepPink, DeepSkyBlue, DimGray, DodgerBlue, Firebrick, FloralWhite, ForestGreen, Fuchsia, Gainsboro, GhostWhite, Gold, Goldenrod, Gray, Green, GreenYellow, Honeydew, HotPink, IndianRed, Indigo, Ivory, Khaki, Lavender, LavenderBlush, LawnGreen, LemonChiffon, LightBlue, LightCoral, LightCyan, LightGoldenrodYellow, LightGray, LightGreen, LightPink, LightSalmon, LightSeaGreen, LightSkyBlue, LightSlateGray, LightSteelBlue, LightYellow, Lime, LimeGreen, Linen, Magenta, Maroon, MediumAquamarine, MediumBlue, MediumOrchid, MediumPurple, MediumSeaGreen, MediumSlateBlue, MediumSpringGreen, MediumTurquoise, MediumVioletRed, MidnightBlue, MintCream, MistyRose, Moccasin, NavajoWhite, Navy, OldLace, Olive, OliveDrab, Orange, OrangeRed, Orchid, PaleGoldenrod, PaleGreen, PaleTurquoise, PaleVioletRed, PapayaWhip, PeachPuff, Peru, Pink, Plum, PowderBlue, Purple, Red, RosyBrown, RoyalBlue, SaddleBrown, Salmon, SandyBrown, SeaGreen, SeaShell, Sienna, Silver, SkyBlue, SlateBlue, SlateGray, Snow, SpringGreen, SteelBlue, Tan, Teal, Thistle, Tomato, Transparent, Turquoise, Violet, Wheat, White, WhiteSmoke, Yellow, YellowGreen

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CornerRadius
{{ Fill CornerRadius Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CustomButtons
{{ Fill CustomButtons Description }}

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FontFamily
{{ Fill FontFamily Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: 3270Medium Nerd Font Mono, 3270Medium NF, 3270Narrow Nerd Font, 3270Narrow Nerd Font Mono, 3270Narrow NF, 3270SemiNarrow Nerd Font, 3270SemiNarrow Nerd Font Mono, 3270SemiNarrow NF, agave Nerd Font, agave Nerd Font Mono, agave NF, Arial, Arial Black, Bahnschrift, Bahnschrift Condensed, Bahnschrift Light, Bahnschrift Light Condensed, Bahnschrift Light SemiCondensed, Bahnschrift SemiBold, Bahnschrift SemiBold Condensed, Bahnschrift SemiBold SemiConden, Bahnschrift SemiCondensed, Bahnschrift SemiLight, Bahnschrift SemiLight Condensed, Bahnschrift SemiLight SemiConde, Caladea, Calibri, Calibri Light, Cambria, Cambria Math, Candara, Candara Light, Carlito, Cascadia Code, Cascadia Code ExtraLight, Cascadia Code Light, Cascadia Code SemiBold, Cascadia Code SemiLight, Cascadia Mono, Cascadia Mono ExtraLight, Cascadia Mono Light, Cascadia Mono SemiBold, Cascadia Mono SemiLight, Comic Sans MS, Consolas, Constantia, Corbel, Corbel Light, Courier New, DejaVu Sans, DejaVu Sans Condensed, DejaVu Sans Light, DejaVu Sans Mono, DejaVu Serif, DejaVu Serif Condensed, Ebrima, Franklin Gothic Medium, Gabriola, Gadugi, Gentium Basic, Gentium Book Basic, Georgia, HoloLens MDL2 Assets, Impact, Ink Free, Javanese Text, Leelawadee UI, Leelawadee UI Semilight, LiterationMono Nerd Font, LiterationMono Nerd Font Mono, LiterationMono NF, Lucida Console, Lucida Sans Unicode, Malgun Gothic, Malgun Gothic Semilight, Marlett, Microsoft Himalaya, Microsoft JhengHei, Microsoft JhengHei Light, Microsoft JhengHei UI, Microsoft JhengHei UI Light, Microsoft New Tai Lue, Microsoft PhagsPa, Microsoft Sans Serif, Microsoft Tai Le, Microsoft YaHei, Microsoft YaHei Light, Microsoft YaHei UI, Microsoft YaHei UI Light, Microsoft Yi Baiti, MingLiU-ExtB, MingLiU_HKSCS-ExtB, Mongolian Baiti, Monofur Nerd Font, Monofur Nerd Font Mono, Monofur NF, Monofurbold Nerd Font, Monofurbold Nerd Font Mono, Monofurbold NF, Monofuritalic Nerd Font, Monofuritalic Nerd Font Mono, Monofuritalic NF, MS Gothic, MS PGothic, MS UI Gothic, MV Boli, Myanmar Text, Nirmala UI, Nirmala UI Semilight, NSimSun, OpenSymbol, Palatino Linotype, PMingLiU-ExtB, Segoe MDL2 Assets, Segoe Print, Segoe Script, Segoe UI, Segoe UI Black, Segoe UI Emoji, Segoe UI Historic, Segoe UI Light, Segoe UI Semibold, Segoe UI Semilight, Segoe UI Symbol, SimSun, SimSun-ExtB, Sitka Banner, Sitka Display, Sitka Heading, Sitka Small, Sitka Subheading, Sitka Text, Sylfaen, Symbol, Tahoma, Times New Roman, Trebuchet MS, Verdana, Webdings, Wingdings, Yu Gothic, Yu Gothic Light, Yu Gothic Medium, Yu Gothic UI, Yu Gothic UI Light, Yu Gothic UI Semibold, Yu Gothic UI Semilight

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnClosed
{{ Fill OnClosed Description }}

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnLoaded
{{ Fill OnLoaded Description }}

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShadowDepth
{{ Fill ShadowDepth Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Timeout
{{ Fill Timeout Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Title
{{ Fill Title Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TitleBackground
{{ Fill TitleBackground Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AliceBlue, AntiqueWhite, Aqua, Aquamarine, Azure, Beige, Bisque, Black, BlanchedAlmond, Blue, BlueViolet, Brown, BurlyWood, CadetBlue, Chartreuse, Chocolate, Coral, CornflowerBlue, Cornsilk, Crimson, Cyan, DarkBlue, DarkCyan, DarkGoldenrod, DarkGray, DarkGreen, DarkKhaki, DarkMagenta, DarkOliveGreen, DarkOrange, DarkOrchid, DarkRed, DarkSalmon, DarkSeaGreen, DarkSlateBlue, DarkSlateGray, DarkTurquoise, DarkViolet, DeepPink, DeepSkyBlue, DimGray, DodgerBlue, Firebrick, FloralWhite, ForestGreen, Fuchsia, Gainsboro, GhostWhite, Gold, Goldenrod, Gray, Green, GreenYellow, Honeydew, HotPink, IndianRed, Indigo, Ivory, Khaki, Lavender, LavenderBlush, LawnGreen, LemonChiffon, LightBlue, LightCoral, LightCyan, LightGoldenrodYellow, LightGray, LightGreen, LightPink, LightSalmon, LightSeaGreen, LightSkyBlue, LightSlateGray, LightSteelBlue, LightYellow, Lime, LimeGreen, Linen, Magenta, Maroon, MediumAquamarine, MediumBlue, MediumOrchid, MediumPurple, MediumSeaGreen, MediumSlateBlue, MediumSpringGreen, MediumTurquoise, MediumVioletRed, MidnightBlue, MintCream, MistyRose, Moccasin, NavajoWhite, Navy, OldLace, Olive, OliveDrab, Orange, OrangeRed, Orchid, PaleGoldenrod, PaleGreen, PaleTurquoise, PaleVioletRed, PapayaWhip, PeachPuff, Peru, Pink, Plum, PowderBlue, Purple, Red, RosyBrown, RoyalBlue, SaddleBrown, Salmon, SandyBrown, SeaGreen, SeaShell, Sienna, Silver, SkyBlue, SlateBlue, SlateGray, Snow, SpringGreen, SteelBlue, Tan, Teal, Thistle, Tomato, Transparent, Turquoise, Violet, Wheat, White, WhiteSmoke, Yellow, YellowGreen

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TitleFontSize
{{ Fill TitleFontSize Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TitleFontWeight
{{ Fill TitleFontWeight Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Black, Bold, DemiBold, ExtraBlack, ExtraBold, ExtraLight, Heavy, Light, Medium, Normal, Regular, SemiBold, Thin, UltraBlack, UltraBold, UltraLight

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TitleTextForeground
{{ Fill TitleTextForeground Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: AliceBlue, AntiqueWhite, Aqua, Aquamarine, Azure, Beige, Bisque, Black, BlanchedAlmond, Blue, BlueViolet, Brown, BurlyWood, CadetBlue, Chartreuse, Chocolate, Coral, CornflowerBlue, Cornsilk, Crimson, Cyan, DarkBlue, DarkCyan, DarkGoldenrod, DarkGray, DarkGreen, DarkKhaki, DarkMagenta, DarkOliveGreen, DarkOrange, DarkOrchid, DarkRed, DarkSalmon, DarkSeaGreen, DarkSlateBlue, DarkSlateGray, DarkTurquoise, DarkViolet, DeepPink, DeepSkyBlue, DimGray, DodgerBlue, Firebrick, FloralWhite, ForestGreen, Fuchsia, Gainsboro, GhostWhite, Gold, Goldenrod, Gray, Green, GreenYellow, Honeydew, HotPink, IndianRed, Indigo, Ivory, Khaki, Lavender, LavenderBlush, LawnGreen, LemonChiffon, LightBlue, LightCoral, LightCyan, LightGoldenrodYellow, LightGray, LightGreen, LightPink, LightSalmon, LightSeaGreen, LightSkyBlue, LightSlateGray, LightSteelBlue, LightYellow, Lime, LimeGreen, Linen, Magenta, Maroon, MediumAquamarine, MediumBlue, MediumOrchid, MediumPurple, MediumSeaGreen, MediumSlateBlue, MediumSpringGreen, MediumTurquoise, MediumVioletRed, MidnightBlue, MintCream, MistyRose, Moccasin, NavajoWhite, Navy, OldLace, Olive, OliveDrab, Orange, OrangeRed, Orchid, PaleGoldenrod, PaleGreen, PaleTurquoise, PaleVioletRed, PapayaWhip, PeachPuff, Peru, Pink, Plum, PowderBlue, Purple, Red, RosyBrown, RoyalBlue, SaddleBrown, Salmon, SandyBrown, SeaGreen, SeaShell, Sienna, Silver, SkyBlue, SlateBlue, SlateGray, Snow, SpringGreen, SteelBlue, Tan, Teal, Thistle, Tomato, Transparent, Turquoise, Violet, Wheat, White, WhiteSmoke, Yellow, YellowGreen

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WindowHost
{{ Fill WindowHost Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
