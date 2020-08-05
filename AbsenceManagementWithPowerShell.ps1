#Start Exchange Session
$MyCred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://Exchange.company.net/PowerShell/ -Authentication Kerberos -Credential $MyCred
Import-PSSession $Session -DisableNameChecking

#Show current configuration of single mailbox
Get-MailboxAutoReplyConfiguration -Identity thomas@company.net

#Show current configuration of all mailboxes
Get-Mailbox | Get-MailboxAutoReplyConfiguration

#Show current configuration of mailboxes where oof is scheduled 
Get-Mailbox | Get-MailboxAutoReplyConfiguration | Where-Object {$_.AutoReplyState -eq “scheduled”}

#Show current configuration of mailboxes where oof is scheduled or enabled
Get-Mailbox | Get-MailboxAutoReplyConfiguration | Where-Object {$_.AutoReplyState -eq “scheduled” -OR $_.AutoReplyState -eq “enabled”}

#Show current configuration of mailboxes where oof is scheduled or enabled (display only names)
Get-Mailbox | Get-MailboxAutoReplyConfiguration | Where-Object { $_.AutoReplyState –eq “scheduled” -OR $_.AutoReplyState -eq “enabled”} | fl identity

#Export current configuration of mailboxes where oof is scheduled or enabled (display only names) in text file
Get-Mailbox | Get-MailboxAutoReplyConfiguration | Where-Object { $_.AutoReplyState –eq “scheduled” -OR $_.AutoReplyState -eq “enabled”}} | fl identity | Out-file -filepath C:\test\result.txt

#Send email with text file of current configuration of mailboxes
Send-MailMessage -From 'Admin <administrator@company.net>' -To 'Theo <theo@company.net>' -Subject 'Weekly report: Out-of-Office' -Body "Please find the list attached" -Attachments C:\test\result.txt -Priority High -DeliveryNotificationOption OnSuccess, OnFailure -SmtpServer 'exchange.company.net'

#Show current configuration of mailboxes in gridview
Get-Mailbox | Get-MailboxAutoReplyConfiguration | Select-Object Identity,Starttime,Endtime,ExternalMessage,InternalMessage |Out-GridView

#Enable auto reply for single user
Set-MailboxAutoReplyConfiguration -Identity Thomas@company.net -AutoReplyState Enabled -InternalMessage "This user is no longer working for us. Please write to Sandra@company.net" -ExternalMessage "This user is no longer working for us. Please write to Sandra@company.net"

#Schedule auto reply for single user
Set-MailboxAutoReplyConfiguration -Identity Thomas@company.net -AutoReplyState Scheduled `
-InternalMessage "I’m on sick leave until 12/07/2019. Your email will not be forwarded." -ExternalMessage "I’m on sick leave until 12/07/2020. Your email will not be forwarded." -EndTime “12/07/2020 00:00:00”

#Generate a text file with all email addresses and removing header and quotation marks
Get-Mailbox |Select-Object PrimarySmtpAddress | ConvertTo-CSV -NoTypeInformation | Select-Object -Skip 1| %{$_ -replace ‘"‘,“”}| out-file C:\test\user.txt

#Set scheduled auto reply for all users in user.txt
$Users = Get-Content C:\test\user.txt
$(foreach ($User in $Users) 
{Set-MailboxAutoReplyConfiguration $User –AutoReplyState Scheduled –StartTime “08/09/2020” –EndTime “10/09/2020” –ExternalMessage “At the moment I’m attending a training event. I will answer your email asap.” –InternalMessage " At the moment I’m attending a training event. I will answer your email asap.”
})


