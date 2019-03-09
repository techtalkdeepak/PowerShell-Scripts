##This script helps to create and delete a resource lock on all the resource groups in all the subscriptions

Login-AzureRmAccount

$subscriptionlist = Get-AzureRmSubscription | Select Id

Foreach ($sub in $subscriptionlist) 
{

#Select each subscription

set-azurermcontext -Subscription $sub.Id

#List all the resource groups in the subscription

$resourceGroupNames = Get-AzureRmResourceGroup | Select ResourceGroupName


#Begin loop for Resource Groups
    
    $RGName = Get-AzureRmResourceGroup

    foreach($RG in $RGName)

    {
       New-AzureRMResourceLock -LockName "LockRG" -LockLevel CanNotDelete -ResourceGroupName $RG.ResourceGroupName -Force
    }

 }
