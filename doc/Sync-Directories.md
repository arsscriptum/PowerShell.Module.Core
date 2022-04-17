---
external help file: PowerShell.Module.Core-help.xml
Module Name: PowerShell.Module.Core
online version:
schema: 2.0.0
---

# Sync-Directories

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Sync-Directories [-Source] <String> [-Destination] <String> [-SyncType <String>] [-Log <String>] [-BackupMode]
 [-Test] [<CommonParameters>]
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

### -BackupMode
{{ Fill BackupMode Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: b

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Destination
{{ Fill Destination Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: d, dst

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Log
{{ Fill Log Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: l

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source
{{ Fill Source Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: s, src

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SyncType
{{ Fill SyncType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: t, type
Accepted values: MIRROR, COPY, NOCOPY

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Test
{{ Fill Test Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
