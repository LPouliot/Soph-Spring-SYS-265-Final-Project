# This Powershell Script can install AD Domain Services, initialize a forest, and promote a server to a domain controller in an existing domain
# Author: Savannah Ciak
# Champlain College
# 8 April, 2024

# Installing ADDS Option
$hostname = hostname
echo "Would you like to install AD Domain Services on the '$hostname' server? y/n:" 
$answer01 = Read-Host
if ($answer01 -eq 'y') || ($answer01 -eq 'Y') {
   Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
   echo "ADDS services installed."
}
elseif ($answer01 -ne 'y') || ($answer01 -ne 'Y') {
    echo "No ADDS services installed."
}

# Primary Domain Controller Prompting Option
echo "Do you want to promote '$hostname' to a primary domain controller? Saying yes will ask for the domain creation name. y/n:"
$answer02 = Read-Host
if ($answer02 -eq 'y') || ($answer02 -eq 'Y') { 
   echo "What is the name of the domain you wish to create? Include any extensions (ex. name.local):" 
   $domain_name = Read-Host
   Install-ADDSForest -DomainName $domain_name
}
elseif ($answer02 -eq 'n') || ($answer02 -eq 'N') { 
   echo "Do you want to promote '$hostname' to a secondary domain controller? y/n:"
   $answer03 = Read-Host
   if ($answer03 -eq 'y') || ($answer03 -eq 'Y') { 
      echo "What is the name of the domain you wish to add '$hostname' to? Include any extensions (ex. name.local):"
      $domain_name = Read-Host

      echo "What is the IP of the primary domain controller? Do not include CIDR:"
      $dc_address = Read-Host

   $displayID = Get-NetAdapter | Select-Object InterfaceIndex
   Write-Host $displayID

   echo "Please type in the Interface Index number displayed above:" 
   $interfaceID = Read-Host

   Set-DNSClientServerAddress -InterfaceIndex "$interfaceID" -ServerAddress "$dc_address, 127.0.0.1"

   echo "Please enter the login name for the domain admin on the primary domain controller like domain\Administrator:"
   $domainadmin = Read-Host
   echo "Please enter the password for that domain admin:" 
   $domainpasswd = Read-Host -AsSecureString

   Install-ADDSDomainController -InstallDns -Credential (Get-Credential $domainadmin) -DomainName $domain_name -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "$domainpasswd" -Force)
   }
}
