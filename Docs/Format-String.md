---
external help file: FormatFunctions-help.xml
online version: 
schema: 2.0.0
---

# Format-String

## SYNOPSIS
Options for formatting strings.

## SYNTAX

```
Format-String [-Text] <String> [-Reverse] [-Case <String>] [-Replace <Hashtable>] [-Randomize]
```

## DESCRIPTION
Use this command to apply different types of formatting to strings. You can apply multiple transformations.

They are applied in this order:

1) Reverse
2) Randomization
3) Replace
4) Case

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
PS C:\> "P@ssw0rd" | format-string -Reverse

dr0wss@P
```
### -------------------------- EXAMPLE 2 --------------------------
```
PS C:\> "P@ssw0rd" | format-string -Reverse -Randomize

rs0Pd@ws
```
### -------------------------- EXAMPLE 3 --------------------------
```
PS C:\> $env:computername | format-string -Case Lower

win81-ent-01
```
### -------------------------- EXAMPLE 4 --------------------------
```
PS C:\> format-string "p*wer2she!!" -Case Alternate

P*WeR2ShE!!
```
### -------------------------- EXAMPLE 5 --------------------------
```
PS C:\> format-string "alphabet" -Randomize -Replace @{a="@";e=3} -Case Alternate

3bPl@tH@
```

### -------------------------- EXAMPLE 6 --------------------------
```
PS C:\> "pOWERSHELL" | Format-string -Case Toggle

Powershell
```

## PARAMETERS

### -Text
Any string you want to format.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Reverse
Reverse the text string.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Case
Valid values are Upper, Lower, Proper, Alternate, and Toggle. 

Proper case will capitalize the first letter of the string.

Alternate case will alternate between upper and lower case, starting with upper case, e.g.
PoWeRsHeLl

Toggle case will make upper case lower and vice versa, e.g.
Powershell -\> pOWERSHELL

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Replace
Specify a hashtable of replacement values. The hashtable key is the string you want to replace and the value is the replacement (see examples).
Replacement keys are CASE SENSITIVE.


```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Randomize
re-arrange the text in a random order.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### System.String

## OUTPUTS

### System.String

## NOTES
Last Updated: March 30, 2016

Version     : 1.1.4

## RELATED LINKS

[Format-Value]()

[Format-Percent]()

