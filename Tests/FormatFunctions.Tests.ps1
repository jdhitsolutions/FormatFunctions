#Pester Tests for FormatFunctions module

#the module to be tested is not in PSModulePath so explicitly import it
Import-Module ..\FormatFunctions

InModuleScope FormatFunctions {
    Describe "Format-Percent" {

        It "Should work with without error" {
            {Format-Percent -Value 1 -Total 1 -Decimal 0} | Should Not Throw
        }

        It "should format 1234.567/5000 to 4 decimal places" {
            $result = Format-Percent -value 1234.567 -total 5000 -decimal 4 
            $result | Should be 24.6913
        }

        It "Formatting 10/10 with default values should be 100" {
            Format-Percent -Value 10 -Total 10 | Should Be 100
        }
        
        It "Should fail if Total is 0" {
            {Format-Percent -Value 10 -Total 0 }| should Throw
        }

        It "Result should be a string" {
            $result = Format-Percent -Value 10 -Total 123 -AsString
            $result.GetType().Name | Should be "String"
        }
    } #Describe Format-Percent

    Describe "Format-Value" {

    It "Should work without error" {
       { Format-Value -InputObject 1} | Should Not Throw
    }

    Context Values {
    It "Should format as local currency [$((get-culture).NumberFormat.CurrencySymbol)]" {
        Format-Value -InputObject 1.23 -AsCurrency | Should Match (get-culture).NumberFormat.CurrencySymbol
    }
     It "Should format 12345678.9765 to 2 decimal points as a number" {
        $result = 12345678.9765 | format-value -AsNumber -Decimal 2
        $result | Should Match "\.\d{2}$"
        $result | Should Match ","
    }
    It "Should autodetect 1234567890 as 1" {
        Format-Value -InputObject 1234567890 -Autodetect | Should Be 1
    }
    It "Should autodetect 1234567890 to 2 decimal points as 1.15" {
        Format-Value -InputObject 1234567890 -Decimal 2 -Autodetect | Should be 1.15
    }
    It "Should format 1234567890 as a comma separated number" {
        Format-Value -InputObject 1234567890 -AsNumber | Should be "1,234,567,890"
    }
    } #Context Values

    Context CIMTest {
        Mock Get-CimInstance {
           $data = [pscustomobject]@{
           PSComputername = $env:computername
           Size = 100GB
           FreeSpace = 500MB
           DeviceID = "C:"
          }
          Return $Data
        } -ParameterFilter {$Classname -eq "Win32_LogicalDisk" -AND $filter -eq "DeviceID='C:'"}
        
        It "Should format C: Drive size as GB" {
         $result = Get-CimInstance win32_logicaldisk -filter "DeviceID='C:'" | 
         Select PSComputername,DeviceID,
         @{Name="SizeGB";Expression={Format-Value -InputObject $_.Size -Unit GB}},
         @{Name="FreeGB";Expression={Format-Value -InputObject $_.FreeSpace -Unit GB}}
         
         $result.SizeGB | Should Be 100
        }
    } #Context CIMTest

  } #Describe Format-Value
  
    Describe "Format-String" {
        $text = "abcdef"

        It "Should reverse text" {
         Format-String -Text $Text -Reverse | Should BeExactly "fedcba"
        }

        It "Should convert to upper case" {
           Format-String -Text $text -Case Upper | Should BeExactly "ABCDEF"
        }

        It "Should convert to toggled case" {
            Format-String -Text "aBcDeF" -case Toggle | Should BeExactly "AbCdEf"
        }
        
        It "Should alternate case" {
            Format-String -Text "PowerShell" -Case Alternate | Should BeExactly "PoWeRsHeLl"
        }
        It "Should convert proper case" {
            Format-String -Text 'windows' -Case Proper | Should BeExactly 'Windows'
        }

        It "Should replace 'f' in $text with X" {
            Format-String -Text $text -Replace @{f="X"} | Should BeExactly "abcdeX"
        }

    }#describe Format-String
  Describe Aliases {
      It "Should resolve alias fp to Format-Percent" {
       (get-alias fp).ResolvedCommand.Name | Should Be "Format-Percent"
      }

      It "Should resolve alias fv to Format-Value" {
       (get-alias fv).ResolvedCommand.Name | Should Be "Format-Value"
      }

      It "Should resolve alias fs to Format-String" {
       (get-alias fs).ResolvedCommand.Name | Should Be "Format-String"
      }


  } #describe alias
} #inModuleScope