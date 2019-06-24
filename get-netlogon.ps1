$result = "netlogon-combinedresult.csv"
$temp = "c:\temp\test"
remove-item $temp\$result -ErrorAction SilentlyContinue
$server1 = ""
$server2 = ""
$paths = "C:\temp\netlogon.log" #,"\\$server1\C$\windows\debug\netlogon.bak","\\$server2\C$\windows\debug\netlogon.bak"
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

$text = [io.file]::readalltext("$temp\netlogon-combined.csv")
$text.replace("[LOGON]","").replace("from",",").replace("SamLogon:",",").replace('"','')  | Out-File $temp\netlogon.csv


select-string "0xC0000064","0xC000006C","0xc000006D","0xC0000071","0xC0000072","0xC0000193","0xC0000224","0xC0000234","0xC000006A","0xC000005E" -path "$temp\netlogon.csv" | `
select-string -Pattern "CRITICAL" -NotMatch | export-csv $temp\netlogon-2.csv -NoTypeInformation

Import-Csv $temp\netlogon-2.csv | Select-Object -expandproperty line | Out-File $temp\netlogon-result.csv 
Import-Csv $temp\netlogon-result.csv |export-csv $temp\netlogon-combinedresult.csv -NoTypeInformation

get-childitem $temp\netlogon*.csv | ? {$_.name -ne "netlogon-combinedresult.csv"} | remove-item 
# remove-item $temp\netlogon.txt  -Force



# send-mailmessage -to $to -from $from -SmtpServer $mail_server -port $port `
# -Subject $subject -Attachments $temp\netlogon-combinedresult.csv

