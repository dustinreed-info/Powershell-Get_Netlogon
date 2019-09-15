#Powershell-Get_Netlogon
Powershell script to help identify AD Lockouts.  Basically it emulates the Windows Account Lockout tool, NLParse, and allows you to run as scheduled task to generate CSV or email that can help you identify what devices are causing account lockouts.

##Requirements
Read permissions to C$ share on Domain Controllers.
You need to enter hostnames for DC(s).
Read/Write permissions to C:\temp\ on local machine.
