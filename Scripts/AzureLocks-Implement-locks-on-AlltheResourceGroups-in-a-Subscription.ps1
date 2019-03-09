##This script helps to create and delete a resource lock on a resource group

Login-AzureRmAccount

select-azurermsubscription -SubscriptionID "Id of your subscription" 

## View the locks applied on a subscription
Get-AzureRmResourceLock | ft

##How to lock all the resource groups in a subscription 

$RGName = Get-AzureRmResourceGroup

    foreach($RG in $RGName)

    {
       New-AzureRMResourceLock -LockName "LockRG" -LockLevel CanNotDelete -ResourceGroupName $RG.ResourceGroupName -Force
    }



##How to unlock all the resource groups in a subscription 

$RGName = Get-AzureRmResourceGroup
foreach($RG in $RGName)

    {
       remove-AzureRMResourceLock -LockName "LockRG" -ResourceGroupName $RG.ResourceGroupName -Force
    }
