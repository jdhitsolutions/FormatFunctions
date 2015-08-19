#requires -version 3.0


<#

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/


  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************

#>

Function Format-Percent {

<#
.Synopsis
Calculate a percent
.Description
This command calculates a percentage of a value from a total, with the formula (value/total)*100. The default is to return a value to 2 decimal places but you can configure that with -Decimal. There is also an option to format the percentage as a string which will include the % symbol.
.Parameter Value
The numerator value. The parameter has aliases of X and Numerator.
.Parameter Total
The denominator value. The parameter has aliases of Y and Denominator.
.Parameter Decimal
The number of decimal places to return between 0 and 15.
.Parameter String
Format the percentage as a string which will include the % symbol. This is done using the -f operator.
.Example
PS C:\> Format-Percent -value 1234.567 -total 5000 -decimal 4
24.6913

Calculate a percentage from 1234.567 out of 5000 (i.e. 1234.567/5000) to 4 decimal points.
.Example
PS C:\> get-ciminstance win32_operatingsystem -computer chi-dc04 | select PSComputername,TotalVisibleMemorySize,@{Name="PctFreeMem";Expression={ Format-Percent $_.FreePhysicalMemory $_.TotalVisibleMemorySize}}

PSComputerName             TotalVisibleMemorySize           PctFreeMem
--------------             ----------------------           ----------
chi-dc04                                  1738292                23.92
.Example
PS C:\> get-ciminstance win32_operatingsystem -computer chi-dc04 | select PSComputername,TotalVisibleMemorySize,@{Name="PctFreeMem";Expression={ Format-Percent $_.FreePhysicalMemory $_.TotalVisibleMemorySize -asString}}
PSComputerName             TotalVisibleMemorySize           PctFreeMem
--------------             ----------------------           ----------
chi-dc04                                  1738292           23.92%

.Notes
Last Updated: August 19, 2015
Version     : 1.1.2

.Link
Format-Value
Format-String
#>

[cmdletbinding(DefaultParameterSetName="None")]
[OutputType([Double],ParameterSetName="None")]
[OutputType([String],ParameterSetName="String")]
Param(
[Parameter(Position=0,Mandatory,HelpMessage="What is the value?")]
[ValidateNotNullorEmpty()]
[Alias("X","Numerator")]
$Value,
[Parameter(Position=1,Mandatory,HelpMessage="What is the total value?")]
[ValidateNotNullorEmpty()]
[Alias("Y","Denominator")]
$Total,
[ValidateNotNullorEmpty()]
[ValidateRange(0,15)]
[int]$Decimal=2,
[Parameter(ParameterSetName="String")]
[Switch]$AsString
)

Write-Verbose "Status: Calculating percentage from $Value/$Total to $decimal places"
$result = $Value/$Total

if ($AsString) {
    Write-Verbose "Status: Writing string result"
    #use the -F operator to build a percent string to X number of decimal places
    $pctstring = "{0:p$Decimal}" -f $result
    #remove the space before the % symbol
    $pctstring.Replace(" ","")

}
else {
    Write-Verbose "Status: Writing numeric result"
    #round the result to the specified number of decimal places
    [math]::Round( ($result*100),$Decimal)
}

} #end function

Function Format-Value {

<#
.Synopsis
Format a numeric value
.Description
This command will format a given numeric value. By default it will treat the number as an integer. Or you can specify a certain number of decimal places. The command will also allow you to format the value in KB, MB, etc. Or you can let the command autodetect the value and divide by an appropriate value.
.Parameter Unit
The unit of measurement for your value. Valid choices are "KB","MB","GB","TB", and "PB". If you don't specify a unit, the value will remain as is, although you can still specify the number of decimal places.
.Parameter Decimal
The number of decimal places to return between 0 and 15.
.Parameter AsCurrency
Format the numeric value as currency using detected cultural settings. The output will be a string.
.Parameter AsNumber
Format the numeric value as a number using detected cultural settings for a separator like a comma. If if incoming value as decimal points, by default they will be removed unless you use -Decimal. The output will be a string.
.Example
PS C:\> Get-CimInstance -class win32_logicaldisk -filter "DriveType=3" | Select DeviceID,@{Name="SizeGB";Expression={$_.size | format-value -unit GB}},@{Name="FreeGB";Expression={$_.freespace | format-value -unit GB -decimal 2}}

DeviceID                            SizeGB                                      FreeGB
--------                            ------                                      ------
C:                                     200                                      124.97
D:                                     437                                       29.01
E:                                      25                                        9.67
.Example
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

.Example
PS C:\Scripts> 3456.5689 | format-value -AsCurrency
$3,456.57

Format a value as currency.

.Example
PS C:\> 1234567.8973 | format-value -AsNumber -Decimal 2
1,234,567.90

Format the value as a number to 2 decimal points.
.Notes
Last Updated: August 19, 2015
Version     : 1.1.2

.Link
Format-String
Format-Percent

#>

[cmdletbinding(DefaultParameterSetName="Default")]

Param(
[Parameter(Position=1,Mandatory,ValueFromPipeline)]
[ValidateNotNullorEmpty()]
$InputObject,
[Parameter(Position=0,ParameterSetName="Default")]
[ValidateSet("KB","MB","GB","TB","PB")]
[string]$Unit,
[ValidateRange(0,15)]
[Parameter(ParameterSetName = "Default")]
[Parameter(ParameterSetName = "Auto")]
[Parameter(ParameterSetName="Number")]
[int]$Decimal,
[Parameter(ParameterSetName="Auto")]
[switch]$Autodetect,
[Parameter(ParameterSetName="Currency")]
[switch]$AsCurrency,
[Parameter(ParameterSetName="Number")]
[switch]$AsNumber
)

Begin {
    Write-Verbose "Starting: $($MyInvocation.Mycommand)"  
    Write-Verbose "Status: Using parameter set $($PSCmdlet.ParameterSetName)"
} #begin

Process {
    Write-Verbose "Status: Formatting $Inputobject"

    <#
    divide the incoming value by the specified unit
    There is no need to process other statements so I'm using the Break keyword
    although in reality the rest of the statements wouldn't be processed anyway
    #>
    Switch ($PSCmdlet.ParameterSetName) {
     "Default"  {
        Write-Verbose "..as $Unit"
        Switch ($Unit) {
         "KB" { $value =  $Inputobject / 1KB ; break }
         "MB" { $value =  $Inputobject / 1MB ; break }
         "GB" { $value =  $Inputobject / 1GB ; break }
         "TB" { $value =  $Inputobject / 1TB ; break }
         "PB" { $value =  $Inputobject / 1PB ; break }
         default { 
          #just use the raw value
          $value = $Inputobject 
          }
        } #default
    }
     "Auto"   {
          Write-Verbose "Status: Using Autodetect"
      
          if ($InputObject -ge 1PB) {
            Write-Verbose "..as PB"
            $value =  $Inputobject / 1PB
          }
          elseif ($InputObject -ge 1TB) {
            Write-Verbose "..as TB"
            $value =  $Inputobject / 1TB
          }
          elseif ($InputObject -ge 1GB) {
            Write-Verbose "..as GB"
            $value =  $Inputobject / 1GB
          }
          elseif ($InputObject -ge 1MB) {
            Write-Verbose "..as MB"
            $value =  $Inputobject / 1MB
          }
          elseif ($InputObject -ge 1KB) {
            Write-Verbose "..as KB"
            $value =  $Inputobject / 1KB
          }
          else { 
            Write-Verbose "..as bytes"
            $value = $InputObject
          }
          Break
      } #Auto
      "Currency"  {
            Write-Verbose "...as currency"
            "{0:c}" -f $InputObject
            #if using currency no other code in the Process block will be run
            Break
      }#Currency
      "Number" {
            Write-Verbose "...as number"
            #if -Decimal not used explicitly set it to 0
            if (-Not $Decimal) {
                $Decimal = 0
            }
            #format as a number to the specified number of decimal points
            "{0:n$($decimal)}" -f $InputObject
            Break
      }
    } #switch parameterset name

    if ($PSCmdlet.ParameterSetName -notmatch "Currency|Number") {
        Write-Verbose "Status: Reformatting $value"
        if ($decimal) {
            Write-Verbose "..to $decimal decimal places"
            #round the number to the specified number of decimal places
            [math]::Round($value,$decimal)
        }
        else {
            #if not a currency and not using a decimal then treat the value as an integer
            #and write the result to the pipeline
            Write-Verbose "..as [int]"
            $value -as [int]
        }
    } #parameter set <> currency
} #process

End {
    Write-Verbose "Ending: $($MyInvocation.Mycommand)"
} #end
} 

Function Format-String {

<#
.Synopsis
Options for formatting strings
.Description
Use this command to apply different types of formatting to strings. You can apply multiple transformations. They are applied in this order:

1) Reverse
2) Randomization
3) Replace
4) Case

.Parameter Case
Valid values are Upper, Lower, Proper, Alternate, and Toggle. 
Proper case will capitalize the first letter of the string.
Alternate case will alternate between upper and lower case, starting with upper case, e.g. PoWeRsHeLl
Toggle case will make upper case lower and vice versa, e.g. Powershell -> pOWERSHELL
.Parameter Replace
Specify a hashtable of replacement values. The hashtable key is the string you want to replace and the value is the replacement. See examples.
Replacement keys are CASE SENSITIVE.
.Example
PS C:\> "P@ssw0rd" | format-string -Reverse
dr0wss@P
.Example
PS C:\> "P@ssw0rd" | format-string -Reverse -Randomize
rs0Pd@ws
.Example
PS C:\> $env:computername | format-string -Case Lower
win81-ent-01
.Example
PS C:\> format-string "p*wer2she!!" -Case Alternate
P*WeR2ShE!!
.Example
PS C:\> format-string "alphabet" -Randomize -Replace @{a="@";e=3} -Case Alternate
3bPl@tH@
.Example
PS C:\> "pOWERSHELL" | Format-string -Case Toggle
Powershell

.Notes
Last Updated: August 19, 2015
Version     : 1.1.3
.Link
Format-Value
Format-Percent
#>

[cmdletbinding()]
[OutputType([string])]
Param(
[Parameter(Position=0,Mandatory,ValueFromPipeline)]
[ValidateNotNullorEmpty()]
[string]$Text,
[switch]$Reverse,
[ValidateSet("Upper","Lower","Proper", "Toggle", "Alternate")]
[string]$Case,
[hashtable]$Replace,
[switch]$Randomize
)

Begin {
    Write-Verbose "Starting: $($MyInvocation.Mycommand)"  
    Write-Verbose "Status: Using parameter set $($PSCmdlet.parameterSetName)"
} #begin

Process {
    Write-Verbose "Status: Processing $Text"
    if ($Reverse) {
        Write-Verbose "Status: Reversing $($Text.length) characters"
        $rev = for ($i=$Text.length; $i -ge 0 ; $i--) { $Text[$i]}
        #join the reverse array back into a string
        $str = $rev -join ""
    }
    else {
        #copy the Text value to this internal variable
        $str = $Text
    } 

    if ($Randomize) {
        Write-Verbose "Status: Randomizing text"
        #get a random number of characters that is the same length as the original string
        #and join them back together
        $str = ($str.ToCharArray() | Get-Random -count $str.length) -join ""
    } #Randomize

    if ($Replace) {
      foreach ($key in $Replace.keys) {
        Write-Verbose "Status: Replacing $key with $($replace.item($key))"
        $str = $str.replace($key,$replace.item($key))
      } #foreach
    } #replace
    Switch ($case) {
    "Upper"  {
        Write-Verbose "Status: Setting to upper case"
        $str = $str.ToUpper()
    } #upper
    "Lower"  {
        Write-Verbose "Status: Setting to lower case"
        $str = $str.ToLower()
    } #lower
    "Proper" {
        Write-Verbose "Status: Setting to proper case"
        $str = "{0}{1}" -f $str[0].toString().toUpper(),-join $str.Substring(1).ToLower()
    } #proper
    "Alternate" {
        Write-Verbose "Status: Setting to alternate case"
        $alter = for ($i = 0 ; $i -lt $str.length ; $i++) {
          #Odd numbers are uppercase
          if ($i%2) {
            $str[$i].ToString().Tolower()
          }
          else {
           $str[$i].ToString().ToUpper()
          }
        } #for
        $str = $alter -join ""
    } #alternate
    "Toggle" {
        Write-Verbose "Status: setting to toggle case"
        <#
            use a regular expression pattern for a case sensitive match
            Other characters like ! and numbers will fail the test 
            but the ToUpper() method will have no effect.
        #>
       
         #code to use methods from [CHAR] which should better handle other cultures
         $toggle = for ($i = 0 ; $i -lt $str.length ; $i++) {
            if ([char]::IsUpper($str[$i])) {
                $str[$i].ToString().ToLower()
            }
             else {
                $str[$i].ToString().ToUpper()
             }
          } #for
            $str = $toggle -join ""
     } #toggle

    Default {
        Write-Verbose "Status: no further formatting"
    }
    }
    #write result to the pipeline
    $str

} #process

End {
    Write-Verbose "Ending: $($MyInvocation.Mycommand)"
} #end
}

Set-Alias -Name fv -Value Format-Value
Set-Alias -Name fp -value Format-Percent
Set-Alias -name fs -value Format-String

Export-ModuleMember -Function * -Alias *