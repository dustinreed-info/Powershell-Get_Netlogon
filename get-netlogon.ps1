$result = "netlogon-combinedresult.csv"
$temp = "c:\temp\test"
remove-item $temp\$result
$server1 = ""
$server2 = ""
$paths = "\\$server1\C$\windows\debug\netlogon.log","\\$server2\C$\windows\debug\netlogon.log" #,"\\$server1\C$\windows\debug\netlogon.bak","\\$server2\C$\windows\debug\netlogon.bak"
$i = 1
$to = "whoever@example.com"
$from = "you@example.com"
$mail_server = "Youremailserver.tld"
$port = 25
$subject = "Your subject here"

foreach ($path in $paths) {  
    copy-item $path $temp\netlogon$i.csv 
    import-csv $temp\netlogon$i.csv  | Export-Csv $temp\netlogon-combined.csv -Append -Force
    $i++
} 
$Csv = dir $temp\netlogon*.csv


[io.file]::readalltext("$temp\netlogon-combined.csv").replace("[LOGON]",",")  |  Out-File $temp\netlogon-1.csv
[io.file]::readalltext("$temp\netlogon-1.csv").replace("from",",") |  Out-File $temp\netlogon.txt
[io.file]::readalltext("$temp\netlogon.txt").replace("SamLogon:",",") |  Out-File $temp\netlogon21.txt
[io.file]::readalltext("$temp\netlogon21.txt").replace('"','') |  Out-File $temp\netlogon.csv

select-string "0xC0000064","0xC000006C","0xc000006D","0xC0000071","0xC0000072","0xC0000193","0xC0000224","0xC0000234","0xC000006A" -path "$temp\netlogon.csv" | `
select-string -Pattern "CRITICAL" -NotMatch | export-csv $temp\netlogon-2.csv -NoTypeInformation

Import-Csv $temp\netlogon-2.csv | select -expandproperty line | Out-File $temp\netlogon-result.csv 
Import-Csv $temp\netlogon-result.csv |export-csv $temp\netlogon-combinedresult.csv -NoTypeInformation

get-childitem $temp\*.csv | ? {$_.name -ne "netlogon-combinedresult.csv"} | remove-item 
remove-item $temp\netlogon.txt  -Force


#$B = Out-File $temp\netlogon-combinedresult.html 



send-mailmessage -to "dreed@portfoliopathway.com" -from "dra@portfoliopathway.com" -SmtpServer "pp-prd-exc.portfoliopathway.com" -port 25250 `
-Subject "Portfolio Pathway Failed NetLogons" -Attachments $temp\netlogon-combinedresult.csv

$b = import-csv $temp\netlogon-combinedresult.csv | Out-String

#if ($b -like "*ccmfile*") {
    $temp = "c:\temp\test"
    $paths = "\\storage.ccmg.com\C$\windows\debug\netlogon.log","\\ccm-vhost1.ccmg.com\C$\windows\debug\netlogon.log"#,"\\storage.ccmg.com\C$\windows\debug\netlogon.bak","\\ccm-vhost1.ccmg.com\C$\windows\debug\netlogon.bak"
    $i = 1
    
    foreach ($path in $paths) {  
        copy $path $temp\ccmg-netlogon$i.csv 
        import-csv $temp\ccmg-netlogon$i.csv  | Out-File $temp\ccmg-netlogon-combined.csv -Append
        $i++
    } 
    $Csv = dir $temp\ccmg-netlogon*.csv
    
    #foreach ($C in $CSV) { 
    #import-csv $c  | Out-File $temp\netlogon-combined.csv -Append 
    #}
    [io.file]::readalltext("$temp\ccmg-netlogon-combined.csv").replace("[LOGON]",",")  |  Out-File $temp\ccmg-netlogon-1.csv
    [io.file]::readalltext("$temp\ccmg-netlogon-1.csv").replace("from",",") |  Out-File $temp\ccmg-netlogon.txt
    [io.file]::readalltext("$temp\ccmg-netlogon.txt").replace("SamLogon:",",") |  Out-File $temp\ccmg-netlogon21.txt
    [io.file]::readalltext("$temp\ccmg-netlogon21.txt").replace('"','') |  Out-File $temp\ccmg-netlogon.csv
    
    select-string "0xC0000064","0xC000006C","0xc000006D","0xC0000071","0xC0000072","0xC0000193","0xC0000224","0xC0000234" -path "$temp\ccmg-netlogon.csv" | `
    select-string -Pattern "CRITICAL" -NotMatch | export-csv $temp\ccmg-netlogon-2.csv -NoTypeInformation
    
    Import-Csv $temp\ccmg-netlogon-2.csv | select -expandproperty line | Out-File $temp\ccmg-netlogon-result.csv 
    Import-Csv $temp\ccmg-netlogon-result.csv | export-csv $temp\ccmg-netlogon-combinedresult.csv -NoTypeInformation
    
   
    remove-item $temp\ccmg-netlogon.txt  -Force
    
    
send-mailmessage -to $to -from $from -SmtpServer $mail_server -port $port `
-Subject $subject -Attachments $temp\ccmg-netlogon-combinedresult.csv

get-childitem $temp\*.csv | ? {$_.name -ne "netlogon-combinedresult.csv" -or "ccmg-netlogon-combinedresult.csv"} | remove-item 
