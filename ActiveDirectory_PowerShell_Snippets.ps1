# Install AD module on Windows 10
Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online

# Install AD module on Windows Server
Install-WindowsFeature -Name “RSAT-AD-PowerShell” -IncludeAllSubFeature

Import-Module ActiveDirecory

# Connect to via PowerShell remoting
Enter-PSSession -ComputerName DCDomain1 –credential company\administrator

# Available CmdLets
get-command -module ActiveDirectory
get-command -module ActiveDirectory -Verb get,disable
get-command -module ActiveDirectory -Noun ADAccount
get-command -module ActiveDirectory |Measure-Object

# Domain Controller
Get-ADDomain

# Computer Management
Get-ADComputer -Filter *

New-ADComputer -Name "Computer001" -SamAccountName "Computer001" -Path "CN=Computers,DC=Company,DC=net"

# User Management
Get-ADUser -filter * -Properties Name, PasswordNeverExpires,LastLogonDate | Select-Object DistinguishedName,Name,Enabled,PasswordNeverExpires,LastLogonDate
Get-ADUser -filter * -SearchBase "OU=NA,DC=company,DC=net" -Properties Name, PasswordNeverExpires | Select-Object *
Get-ADUser -filter * -SearchBase "OU=NA,DC=company,DC=net" -Properties Name, PasswordNeverExpires,PwdLastSet | Select-Object DistinguishedName,Name,Enabled,PasswordNeverExpires,PwdLastSet


'OU=NA,DC=company,DC=net','OU=EMEA,DC=company,DC=net','OU=APAC,DC=company,DC=net' | ForEach-Object {
    
     Get-ADUser -Filter * -SearchBase $_ -Properties DisplayName,EmailAddress
     } | Select Name,GivenName,Surname,DisplayName,SamAccountName,EmailAddress | Export-Csv C:\Test\userList.csv -NoTypeInformation



# Find all users with password set to never expire

Get-ADUser -filter * -properties Name,PasswordNeverExpires | where {$_.passwordNeverExpires -like "True" } | Select-Object DistinguishedName,Name,Enabled,PasswordNeverExpires

Get-ADUser -filter * -SearchBase "OU=NA,DC=company,DC=net" -properties Name, PasswordNeverExpires | where {$_.PasswordNeverExpires -like "false" } | Select-Object DistinguishedName,Name,Enabled,PasswordNeverExpires

# Force Password Change at next login
Set-ADUser -Identity Tom -ChangePasswordAtLogon $true
Set-ADUser -Identity Sandra -PasswordNeverExpires $false

# Set-ADUser properties for multiple users at once
$users = Get-ADUser -filter * -SearchBase "OU=NA,DC=company,DC=net" -properties Name, PasswordNeverExpires | where {$_.passwordNeverExpires -like "False" } | Select-Object DistinguishedName,Name,Enabled,PasswordNeverExpires,ChangePasswordAtLogon
foreach ($user in $users) {Set-ADUser -Identity $user.name -PasswordNeverExpires $false -ChangePasswordAtLogon $false -Verbose} 


# Set new User password

$NewPassword = ConvertTo-SecureString "P@ssword123!" -AsPlainText -Force

Set-ADAccountPassword -Identity Tom -NewPassword $NewPassword -Reset
Set-ADUser -Identity Tom -ChangePasswordAtLogon $true

# Set new password for multiple users
$myusers = Get-ADUser -filter * -SearchBase "OU=NA,DC=company,DC=net"
 foreach ($user in $myusers) {
     #Generate a random password
     $password = -join ((50..126) | Get-Random -Count 8 | ForEach-Object { [char]$_ })
     #Convert the password to secure string
     $NewPassword = ConvertTo-SecureString $password -AsPlainText -Force
     #Assign the new password to user
     Set-ADAccountPassword $user -NewPassword $NewPassword -Reset
     #Force user to change password at next logon
     Set-ADUser -Identity $user -ChangePasswordAtLogon $true
     #Display username and new password
     Write-Host User: $user,Password: $password
 }

# Find users that have not login in for a long time (and disable these users)

$When = ((Get-Date).AddDays(-30)).Date
Get-ADUser -Filter {LastLogonDate -lt $When} -SearchBase 'OU=UK,OU=EMEA,DC=company,DC=net' -Properties * | select-object samaccountname,givenname,surname,LastLogonDate,distinguishedname #|Disable-ADAccount -WhatIf



$d = [DateTime]::Today.AddDays(-180)
Get-ADUser -Filter '(PasswordLastSet -lt $d) -or (LastLogonTimestamp -lt $d)' -Properties PasswordLastSet,LastLogonTimestamp | ft Name,PasswordLastSet,@{N="LastLogonTimestamp";E={[datetime]::FromFileTime($_.LastLogonTimestamp)}}


# Create new AD User with password entry
New-ADUser -Name "Adam Smith" -GivenName "Adam" -Surname "Smith" -SamAccountName "ASmith" -UserPrincipalName "Adam.Smith@company.net" -Path "OU=Sales,OU=US,OU=NA,DC=company,DC=net" -AccountPassword(Read-Host -AsSecureString "P@ssword123!") -Enabled $true -WhatIf





# Create new OUs

$ous = @(("Concerts UK Inc"),("Concerts USA Inc"),("Concerts Canada Inc"),("Concerts Australia Inc"))
 foreach($ou in $ous)
 {
 $newou = New-ADOrganizationalUnit -Name $ou -Path "DC=company,DC=net" -ProtectedFromAccidentalDeletion $false -PassThru
 $ouGroups=New-ADOrganizationalUnit -Name "Groups" -Path $newou.DistinguishedName `
 -Description "Groups" `
 -ProtectedFromAccidentalDeletion $false -PassThru
 $ouUsers=New-ADOrganizationalUnit -Name "Users" -Path $newou.DistinguishedName `
 -Description "Users" `
 -ProtectedFromAccidentalDeletion $false -PassThru }


# Create multiple users based on a csv file

$ADUsers = Import-Csv C:\test\NewUsers.txt -Delimiter ","

# Define UPN
$UPN = "company.net"
# Loop through each row containing user details in the CSV file
foreach ($User in $ADUsers) {

    #Read user data from each field in each row and assign the data to a variable as below
    $username = $User.username
    $password = $User.password
    $firstname = $User.firstname
    $lastname = $User.lastname
    $initials = $User.initials
    $OU = $User.ou #This field refers to the OU the user account is to be created in
    $email = $User.email
    $country = $User.country
    $city = $User.city
    $telephone = $User.telephone
    $company = $User.company
    $department = $User.department

    
    # Check to see if the user already exists in AD
    if (Get-ADUser -F { SamAccountName -eq $username }) {
       
       
    }
    else 
    {

        # User does not exist then proceed to create the new user account
        # Account will be created in the OU provided by the $OU variable read from the CSV file
        New-ADUser `
            -SamAccountName $username `
            -UserPrincipalName "$username@$UPN" `
            -Name "$firstname $lastname" `
            -GivenName $firstname `
            -Surname $lastname `
            -Enabled $True `
            -DisplayName "$lastname, $firstname" `
            -Path $OU `
            -City $city `
            -Country $country `
            -Company $company `
            -OfficePhone $telephone `
            -EmailAddress $email `
            -Department $department `
            -AccountPassword (ConvertTo-secureString ScriptRunner2021! -AsPlainText -Force) -ChangePasswordAtLogon $False
         
      $DepartmentGroup = "$department-$Country"
                        
        if (Get-ADgroup -F { Name -eq $DepartmentGroup} -ErrorAction Continue)
        {
           Add-ADGroupMember -Identity $DepartmentGroup -Members $username
        }
        else 
        {
           New-ADGroup -Name $DepartmentGroup -Path $OU -DisplayName $department -verbose -GroupScope DomainLocal
        }

     $AllGroup = "$company-AllUSers"
    
        if (Get-ADgroup -F { Name -eq $AllGroup } -ErrorAction Continue)
        {
            Add-ADGroupMember -Identity $AllGroup -Members $username
        }
        else 
        {
            New-ADGroup -Name $AllGroup -Path $OU -DisplayName "$OU-AllUsers" -verbose -GroupScope DomainLocal
        }
        
        
         # If user is created, show message.
            }
}



# AD GROUP MANAGEMENT

Get-ADGroupMember -Identity "Team Germany Consulting"






