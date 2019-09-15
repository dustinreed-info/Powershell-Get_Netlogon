$results = "netlogon-results.csv"
$temp = "C:\temp\netlogon"


if ((Test-Path $temp) -eq $False) {
    mkdir $temp
}
remove-item $temp\$results -ErrorAction SilentlyContinue

#Enter Domain Controllers hostname
# $server1 = ""
# $server2 = ""


$paths = "\\$server1\C$\windows\debug\netlogon.log", "\\$server1\C$\windows\debug\netlogon.bak"


#Combines Netlogon files.
$i = 1
foreach ($path in $paths) {  
    Import-Csv $path  | Export-Csv $temp\netlogon-combined.csv -Append -Force -NoTypeInformation
    $i++
} 


#Selects exceptions related to lockouts.
$strings = "0xC0000064","0xC000006C","0xc000006D","0xC0000071","0xC0000072","0xC0000193","0xC0000224","0xC0000234","0xC000006A","0xC000005E"
get-content $temp"\netlogon-combined.csv" | select-string $strings   | out-file $temp"\netlogon-strings.csv"


$text = [io.file]::readalltext("$temp\netlogon-strings.csv")
$text.replace("[LOGON] ","").replace("from ","").replace("SamLogon: ","").replace('"','') | out-file "$temp\$results"


#Cleans $temp directory.
get-childitem $temp\netlogon*.csv | Where-Object {$_.name -ne $results} | remove-item 

#Opens CSV file
Invoke-Expression $temp\$results

###Uncomment if you want to send results via email.
# $to = "whoever@example.com"
# $from = "you@example.com"
# $mail_server = "Youremailserver.tld"
# $port = 25
# $subject = "Your subject here"


# send-mailmessage -to $to -from $from -SmtpServer $mail_server -port $port `
# -Subject $subject -Attachments $temp\$results

