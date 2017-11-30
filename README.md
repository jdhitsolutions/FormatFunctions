#FormatFunctions

## Archived
The code in this project has been moved to [PSScriptTools](https://github.com/jdhitsolutions/PSScriptTools). This repository has been archived.
## Original README
This is a collection of PowerShell functions to make it easier to format data and values.

##Format-Value
This command will format a given numeric value. By default it will treat the number as an integer. Or you can specify a certain number of decimal places. The command will also allow you to format the value in KB, MB, etc. Or you can let the command autodetect the value and divide by an appropriate value.

###Examples    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Get-CimInstance -class win32_logicaldisk -filter "DriveType=3" | Select 
    DeviceID,@{Name="SizeGB";Expression={$_.size | format-value -unit 
    GB}},@{Name="FreeGB";Expression={$_.freespace | format-value -unit GB -decimal 2}}
    
    
    DeviceID                            SizeGB                                      FreeGB
    --------                            ------                                      ------
    C:                                     200                                      124.97
    D:                                     437                                       29.01
    E:                                      25                                        9.67   
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>(get-process chrome | measure ws -sum ).sum | format-value -Autodetect -Decimal 4
    
    920.6133
        
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\Scripts>3456.5689 | format-value -AsCurrency
    
    $3,456.57
    
##Format-String
Use this command to apply different types of formatting to strings. You can apply multiple transformations. 
They are applied in this order:
    
    1) Reverse
    2) Randomization
    3) Replace
    4) Case

###Examples   
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>"P@ssw0rd" | format-string -Reverse
       
    dr0wss@P 
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>"P@ssw0rd" | format-string -Reverse -Randomize
       
    rs0Pd@ws
   
##Format-Percent
This command calculates a percentage of a value from a total, with the formula (value/total)*100. The default is to return a value to 2 decimal places but you can configure that with -Decimal. There is also an option to format the percentage as a string which will include the % symbol.

###Examples  
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Format-Percent -value 1234.567 -total 5000 -decimal 4   
    
    24.6913
    
    Calculate a percentage from 1234.567 out of 5000 (i.e. 1234.567/5000) to 4 decimal points.
     
    -------------------------- EXAMPLE 2 --------------------------
  
    PS C:\>get-ciminstance win32_operatingsystem -computer chi-dc04 | 
    select PSComputername,TotalVisibleMemorySize,@{Name="PctFreeMem";Expression={ Format-Percent 
    $_.FreePhysicalMemory $_.TotalVisibleMemorySize}}
    
    
    PSComputerName             TotalVisibleMemorySize           PctFreeMem
    --------------             ----------------------           ----------
    chi-dc04                                  1738292                23.92
    
    