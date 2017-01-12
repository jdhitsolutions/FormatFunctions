---
external help file: FormatFunctions-help.xml
online version: 
schema: 2.0.0
---

# Format-Value

## SYNOPSIS
Format a numeric value

## SYNTAX

### Default (Default)
```
Format-Value [-InputObject] <Object> [[-Unit] <String>] [-Decimal <Int32>]
```

### Number
```
Format-Value [-InputObject] <Object> [-Decimal <Int32>] [-AsNumber]
```

### Auto
```
Format-Value [-InputObject] <Object> [-Decimal <Int32>] [-Autodetect]
```

### Currency
```
Format-Value [-InputObject] <Object> [-AsCurrency]
```

## DESCRIPTION
This command will format a given numeric value. By default it will treat the number as an integer. Or you can specify a certain number of decimal places. The command will also allow you to format the value in KB, MB, etc.

You can let the command autodetect the value and divide by an appropriate value.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
PS C:\> Get-CimInstance -class win32_logicaldisk -filter "DriveType=3" | Select DeviceID,@{Name="SizeGB";Expression={$_.size | format-value -unit GB}},@{Name="FreeGB";Expression={$_.freespace | format-value -unit GB -decimal 2}}

DeviceID                            SizeGB                                      FreeGB
--------                            ------                                      ------
C:                                     200                                      124.97
D:                                     437                                       29.01
E:                                      25                                        9.67
```

### -------------------------- EXAMPLE 2 --------------------------
```
PS C:\> (get-process chrome | measure ws -sum ).sum | format-value -Autodetect -verbose -Decimal 4

VERBOSE: Starting: Format-Value
VERBOSE: Status: Using parameter set Auto
VERBOSE: Status: Formatting 965332992
VERBOSE: Status: Using Autodetect
VERBOSE: ..as MB
VERBOSE: Status: Reformatting 920.61328125
VERBOSE: ..to 4 decimal places
920.6133
VERBOSE: Ending: Format-Value
```

### -------------------------- EXAMPLE 3 --------------------------
```
PS C:\> 3456.5689 | format-value -AsCurrency

$3,456.57
```
Format a value as currency.

### -------------------------- EXAMPLE 4 --------------------------
```
PS C:\> 1234567.8973 | format-value -AsNumber -Decimal 2


1,234,567.90
```
Format the value as a number to 2 decimal points.

## PARAMETERS

### -InputObject


```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Unit
The unit of measurement for your value.
Valid choices are "KB","MB","GB","TB", and "PB".
If you don't specify a unit, the value will remain as is, although you can still specify the number of decimal places.

```yaml
Type: String
Parameter Sets: Default
Aliases: 

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Decimal
The number of decimal places to return between 0 and 15.

```yaml
Type: Int32
Parameter Sets: Default, Number, Auto
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Autodetect
Attempt to autodetect and format the value.

```yaml
Type: SwitchParameter
Parameter Sets: Auto
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsCurrency
Format the numeric value as currency using detected cultural settings. The output will be a string.

```yaml
Type: SwitchParameter
Parameter Sets: Currency
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsNumber
Format the numeric value as a number using detected cultural settings for a separator like a comma.
If if incoming value as decimal points, by default they will be removed unless you use -Decimal.
The output will be a string.

```yaml
Type: SwitchParameter
Parameter Sets: Number
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS
### System.object
## OUTPUTS
### System.object

## NOTES
Last Updated: March 30, 2016 

Version     : 1.1.3

## RELATED LINKS

[Format-String]()

[Format-Percent]()

