$VMName = "VM Name"
$RGName = "Resource Group Name"

## Login to Azure RM Account
Login-Azurermaccount

## Select an Azure Subscription 
Select-AzureRMSubscription -Subscriptionname "Your Subscription Name"

##Converting an unmanaged VM disk to Managed 

ConvertTo-AzureRmVMManagedDisk -ResourceGroupName $RGName -vmname $VMName