##This script helps to create and delete a resource lock on a resource group

Login-AzureRmAccount

select-azurermsubscription -SubscriptionID "Id of your subscription" 

## View the locks applied on a subscription
Get-AzureRmResourceLock | ft

##How to lock a resource group 

New-AzureRMResourceLock -LockName "LockRG" -LockLevel CanNotDelete -ResourceGroupName "AzureLock-Demo"

##How to remove a lock from a resource group

Remove-AzureRmResourceLock -LockName "LockRG" -ResourceGroupName "AzureLock-Demo"