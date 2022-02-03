
#region COMPUTERLIEBE (DIE MODULE SPIEL'N VERRÜCKT)
#COMPUTERLOVE (THE MODULES ARE GOING CRAZY)
# PowerShell logistics
 
Find-Module -Name ExchangeOnlineManagement | Install-Module -Scope AllUsers
Install-Module -Name ExchangeOnlineManagement

Get-Module -Name ExchangeOnlineManagement -ListAvailable | select Name,Version,Path

get-command -type Cmdlet -module ExchangeOnlineManagement
get-command -module ExchangeOnlineManagement
get-command -module ExchangeOnlineManagement |Measure-Object

#endregion

#region CONNECTED - STEREO MC'S
# Connect to Exchange Online
$cred = Get-Credential
Connect-ExchangeOnline -Credential $cred
Connect-ExchangeOnline
# Disconnect to Exchange Online
Disconnect-ExchangeOnline
#endregion

#region I WANT IT ALL - QUEEN
# Let's take a look at the current state
# Show all Mailboxes

Get-Mailbox
Get-EXOMailbox

Measure-Command {Get-Mailbox}
Measure-Command {Get-EXOMailbox}


Get-Mailbox | Get-MailboxAutoReplyConfiguration -ResultSize unlimited

#Show quotas for all mailboxes
Get-EXOMailbox -PropertySets Quota |select PrimarySmtpAddress,ProhibitSendQuota,ArchiveQuota

#Show quotas, size limits and recipient limits for a particular user
Get-Mailbox -Identity xx.xxx@xxxx.de | select *quota*, *size*, *limit*

#Show Mailbox send/receive limits
Get-EXOMailbox -PropertySets Delivery | select PrimarySmtpAddress,MaxSendSize,MaxReceiveSize,RecipientLimits

Get-EXOMailbox -PropertySets Quota,Delivery -Properties EmailAddresses,RecipientTypeDetails

#Show all Shared Mailboxes
Get-EXOMailbox -PropertySets Delivery -Properties RecipientTypeDetails  | Where-Object{$_.RecipientTypeDetails -eq "SharedMailbox"}  | Sort-Object UserPrincipalName

#Show all User Mailboxes
Get-EXOMailbox -PropertySets Delivery -Properties RecipientTypeDetails  | Where-Object{$_.RecipientTypeDetails -eq "UserMailbox"}  | Sort-Object UserPrincipalName

#Show the top 30 mailboxes
Get-EXOMailbox -ResultSize Unlimited | Get-EXOMailboxStatistics | Sort-Object TotalItemSize -Descending | Select-Object DisplayName,TotalItemSize -First 30

#Show Client Access Services
Get-EXOCasMailbox

#Show IMAP/POP3 settings
Get-EXOCasMailbox -PropertySets Imap,pop

#Show all users with "Full Access" permissions
Get-Mailbox | foreach {
(Get-MailboxPermission -Identity $_.userprincipalname | where{ ($_.AccessRights -contains "FullAccess") -and ($_.IsInherited -eq $false) -and -not ($_.User -match "NT AUTHORITY") }) | select Identity,AccessRights,User}

#Show all users with "Send As" permissions
Get-Mailbox | foreach {
(Get-RecipientPermission -Identity $_.userprincipalname | where{ -not (($_.Trustee -match "NT AUTHORITY") -or ($_.Trustee -match "S-1-5-21"))}) | select Identity,trustee}

#Show all users with "Send on behalf" permissions
Get-Mailbox –ResultSize Unlimited | Where {$_.GrantSendOnBehalfTo -ne $null} | Select UserprincipalName,GrantSendOnBehalfTo

#Show list of all users LastLoginTime and LastUserActionTime
Get-EXOMailbox -ResultSize Unlimited |Foreach{
Get-EXOMailboxStatistics -PropertySets All -Identity $_.UserPrincipalName | Select DisplayName,LastLogonTime,LastUserActionTime} |Sort-Object LastLogonTime -Descending

#Show mailbox statistic for specific user
Get-EXOMailboxStatistics -Identity xx.xx -PropertySets All

#Show mailboxes with configured forwarding addresses

Get-EXOMailbox -ResultSize Unlimited| where {$_.ForwardingAddress -ne $null} | select DisplayName,ForwardingAddress
Get-Mailbox -ResultSize Unlimited | Where-Object {$_.ForwardingAddress -ne $null} | Select-Object Name, @{Expression={$_.ForwardingAddress};Label="Forwarded to"}, @{Expression={$_.DeliverToMailboxAndForward};Label="Mailbox & Forward"}

#Show all group memberships for a specific user
Get-Recipient -Filter "Members -eq 'CN=xx.xxxx,OU=xxx.onmicrosoft.com,OU=Microsoft Exchange Hosted Organizations,DC=EURPR02A007,DC=prod,DC=outlook,DC=com'" | Select-Object Displayname, RecipientType, WhenCreated, PrimarySmtpAddress

#Show all groups managed by a specific user
Get-Recipient -Filter "ManagedBy -eq 'CN=xxx.xx,OU=xxxx.onmicrosoft.com,OU=Microsoft Exchange Hosted Organizations,DC=EURPR02A007,DC=prod,DC=outlook,DC=com'" -RecipientTypeDetails GroupMailbox,MailUniversalDistributionGroup,MailUniversalSecurityGroup,DynamicDistributionGroup | Select-Object Displayname, RecipientType, WhenCreated

#Show Mail traffic report
Get-MailTrafficReport

#Show INBOUND Mail traffic report
Get-MailTrafficReport –Direction Inbound –StartDate 11/13/21 -EndDate 6/20/22

#Show OUTBOUND Mail traffic report
Get-MailTrafficReport –Direction Outbound –StartDate 11/13/21 -EndDate 6/20/22

#Show Top Exchange Online users
Get-MailTrafficTopReport -EventType TopMailUser | Sort-Object MessageCount -Descending

#Show emails based on status (delivered, failed...)
Get-MessageTrace -StartDate ((Get-Date).AddDays(-10)) -EndDate (Get-Date) | Where-Object {$_.Status -eq "Delivered"} | Select-Object Received,SenderAddress,RecipientAddress,Subject,Status|Out-GridView

#endregion

#region UP TO THE LIMIT - ACCEPT
# Manage Mailbox Quotas

# Set quotas for specific user
Set-Mailbox xxx@xxx.de -ProhibitSendQuota 2GB -ProhibitSendReceiveQuota 2GB -IssueWarningQuota 1GB #-WhatIf
Get-Mailbox -Identity xxx.xxx@xxxxx.de | select *quota*, *size*, *limit*

# Set quotas for all users
Get-Mailbox | Set-Mailbox -ProhibitSendQuota 2GB -ProhibitSendReceiveQuota 2GB -IssueWarningQuota 1GB
Get-EXOMailbox -PropertySets Quota |select PrimarySmtpAddress,ProhibitSendQuota,ArchiveQuota

#Set quotas for specific groups 
Get-User | where {$_.Department -eq "Sales"} | Get-Mailbox | Set-Mailbox -ProhibitSendQuota 5GB -ProhibitSendReceiveQuota 5GB -IssueWarningQuota 4GB

#endregion

#region COME TOGETHER - THE BEATLES
# Manage distribution groups

#Show all distribution groups
Get-DistributionGroup |Select-Object Displayname, GroupType, PrimarySmtpAddress, Name, WhenCreated|Sort-Object WhenCreated -Descending|ft

#Show specific distribution groups
Get-DistributionGroup -Filter {name -like "*DL_Test*"}

Get-DistributionGroupMember -Identity "DL_Sales"
Get-DistributionGroup |Get-DistributionGroupMember

#Create new distribution group
New-DistributionGroup -Name "IT Administrators" -Alias itadmin -MemberJoinRestriction open

#Bulk creation for DLs
Import-CSV “C:\temp\DL_ExchangeOnline.csv” | foreach {New-DistributionGroup -Name $_.name -Type $_.Type}

#Delete one distribution group
Remove-DistributionGroup -Identity "DL_Test002" -Confirm:$False

#Delete specific distribution group
Get-DistributionGroup -Filter {name -like "*DL_Test*"} | Remove-DistributionGroup -Confirm:$False  -Whatif

#endregion

#region ROOM WITH A VIEW - TONY CAREY
# Managing Room Mailboxes

#Create new Room Mailboxes
( 0 .. 5 ) | % { New-Mailbox -Name "NY_MeetingRoom00$_" -Room }

#Delete specific Room Mailboxes
Get-Mailbox -Filter {Name -Like "NY_MeetingRoom*"} | Where {$_.ResourceType -eq "Room"}| Remove-Mailbox -Confirm:$False -WhatIf

#Create a new distribution group for a list of Room Mailboxes
$Members = Get-Mailbox -Filter {Name -Like "NY_MeetingRoom*"} | Where {$_.ResourceType -eq "Room"} |Select-Object Name -ExpandProperty name
New-DistributionGroup -Name "NewYorkMeetingRooms" -DisplayName "New YorkMeeting Rooms" -RoomList -Members $Members

#Set Room Mailboxes to automatically accept booking requests

Get-EXOMailbox -PropertySets Delivery -Properties RecipientTypeDetails  | Where-Object{$_.RecipientTypeDetails -eq "RoomMailbox"}  | Sort-Object UserPrincipalName

Get-MailBox | Where {$_.ResourceType -eq "Room"} | Set-CalendarProcessing -AutomateProcessing:AutoAccept

Get-CalendarProcessing -Identity  | Where {$_.ResourceType -eq "Room"} | Format-List

#endregion

#region DREADLOCK HOLIDAY - 10CC
# Managing Out of Office notifications

#Show existing Autoreply notification settings
Get-MailboxAutoReplyConfiguration -Identity xxxx.xxxx@xxxxx.de

Get-Mailbox | Get-MailboxAutoReplyConfiguration -ResultSize unlimited
Get-Mailbox | Get-MailboxAutoReplyConfiguration -ResultSize unlimited |Out-GridView

#Set OOF for one user
Set-MailboxAutoReplyConfiguration -Identity xxx.xx@xxx.de -AutoReplyState Enabled -ExternalMessage "Our current tour is canceled. I'm working from home at the moment. Stay healthy." -InternalMessage "Our current tour is canceled. I'm working from home at the moment. Stay healthy."m

#Set OOF in O365 with start and end date for one user
Set-MailboxAutoReplyConfiguration -Identity xxx.xxx@xxxx.de -AutoReplyState Schedule -StartTime "4/22/2022 08:00:00" -EndTime "6/15/2022 17:00:00" -ExternalMessage "Our current tour is canceled. I'm working from home at the moment. Stay healthy." -InternalMessage "Our current tour is canceled. I'm working from home at the moment. Stay healthy."


#Set OOF in O365 with start and end date (mutiple users)
$Users = Get-Content C:\test\myusers.txt
$(foreach ($User in $Users) {

Set-MailboxAutoReplyConfiguration $User –AutoReplyState Scheduled –StartTime “4/22/2022” –EndTime “6/15/2022” –ExternalMessage "Our current tour is canceled. I'm working from home at the moment. Stay healthy." –InternalMessage "Our current tour is canceled. I'm working from home at the moment. Stay healthy."

#Set OOF for multiple users with multiple start/end dates and different messages
#Requires CSV with "User, ExternalMessage, Internalmessage(, StartDate, EndDate)"
$csv = Import-Csv C:\temp\example.csv

Foreach ($line in $csv) {
Set-MailboxAutoReplyConfiguration $line.user –AutoReplyState Scheduled –StartTime $line.startdate –EndTime $line.enddate –ExternalMessage $line.externalmessage –InternalMessage $line.internalmessage
}

})

#endregion

#region GET THE PARTY STARTED - P!NK

# Create a new mailbox
New-Mailbox -Alias Rick.Beato -Name Rick.Beato -FirstName Rick -LastName Beato -DisplayName "Rick Beato" -MicrosoftOnlineServicesID rick.beato@kraichgau-touristik.de -Password (ConvertTo-SecureString -String 'P@ssw0rd' -AsPlainText -Force) -ResetPasswordOnNextLogon $true

#Bulk mailbox creation

$mbxs = Import-Csv 'C:\users.csv'
Foreach ($mbx in $mbxs) {
New-Mailbox -Name $mbx.DisplayName -DisplayName $mbx.DisplayName -MicrosoftOnlineServicesID $mbx.UserPrincipalName} -Password (ConvertTo-SecureString -String 'YourPassword' -AsPlainText -Force) -ResetPasswordOnNextLogon $true -MailboxPlan 'MailboxPlan'}

#endregion

#region SEEK AND DESTROY - METALLICA
# Deleting stuff

# Show all soft deleted mailboxes
get-mailbox -SoftDeletedMailbox

# Remove single mailbox
Remove-Mailbox -identity mailbox -confirm:$false

# Remove mailboxes based on a name pattern
get-mailbox | where {$_.name -like "NY*"} |Remove-Mailbox -Confirm:$false -WhatIf

# Remove mailboxes based on csv file entries
Import-Csv "C:\temp\DeleteTheseMailboxes.csv" | ForEach-Object {
    Remove-Mailbox -identity $_.mailbox -confirm:$false
}

#Remove specific user from all distribution groups
$email = "xxx.xxx@xxxx.de"
$mailbox = Get-Mailbox -Identity $email
$DN=$mailbox.DistinguishedName
$Filter = "Members -like ""$DN"""
$DistributionGroupsList = Get-DistributionGroup -ResultSize Unlimited -Filter $Filter
    ForEach ($item in $DistributionGroupsList) {
        Remove-DistributionGroupMember -Identity $item.DisplayName –Member $email –BypassSecurityGroupManagerCheck -Confirm:$false
    }

#endregion

#region MESSAGE IN A BOTTLE - THE POLICE
# Send email
$username = "xxx@xxx.onmicrosoft.com"
$password = "xxxxxx"
$sstr = ConvertTo-SecureString -string $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -argumentlist $username, $sstr
$body = "This is a test email"
Send-MailMessage -To "xxx@xxxxx.de" -from "xxx@xxxx.onmicrosoft.com" -Subject 'Test message' -Body $body -BodyAsHtml -smtpserver smtp.office365.com -usessl -Credential $cred -Port 587
#endregion

#region SHOW ME THE WAY - PETER FRAMPTON
# Get help and additional ressources

#Microsoft Exchange PowerShell cheat-sheet
https://lp.scriptrunner.com/en/exchange-cheat-sheet

#Ready-to-use PowerShell scripts for Microsoft Exchange use cases
Start-Process "https://github.com/scriptrunner/ActionPacks/tree/master/Exchange"

#Ready-to-use PowerShell scripts for Microsoft Exchange Online use cases
Start-Process "https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline"

#8-page Cheat Sheet for Microsoft Teams PowerShell Module
Start-Process "https://lp.scriptrunner.com/en/teams-cheat-sheet"

#endregion
