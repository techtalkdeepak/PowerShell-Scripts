##See a list of VMs with Azure Hybrid Use Benefits enabled 

Login-AzureRmAccount

select-azurermsubscription -SubscriptionID "Id of your subscription" 

##List of VMs with all the license Types 
Get-azurermvm| select ResourceGroupName, Name, LicenseType

##List of VMs with Azure Hybrid Use Benefit license type "Windows_Server"

Get-azurermvm| ?{$_.LicenseType -like "Windows_Server"} | select ResourceGroupName, Name, LicenseType

##List of VMs with No Azure Hybrid Use Benefit license type "Windows_Server"

Get-azurermvm| ?{$_.LicenseType -notlike "Windows_Server"} | select ResourceGroupName, Name, LicenseType



