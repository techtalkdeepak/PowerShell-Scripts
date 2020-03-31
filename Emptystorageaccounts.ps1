<#
Description: A list of empty storage accounts
	Type:			Report
	Report:			Empty Storage Accounts
	Output:			Console
	Subscription:	All Subscriptions
#>

#Login to Azure
Login-AzAccount > $null

#Get all subscriptions
$subscriptions = (get-azsubscription).ID

#Define common variables
$emptystg = @()

#Install AzTable module to work with azure storage tables
install-module AzTable -Force

#Loop through all subscriptions
foreach ($sub in $subscriptions)
{
	#Change the subscription context
	Select-AzSubscription -SubscriptionId $sub >> NULL
	
	foreach ($stg in (get-azstorageaccount))
    {

        #Check for the presence of queues in the storage account
        $qb=0
        $queues = get-azstoragequeue -Context $stg.context
        if($queues){foreach ($q in $queues){if($q.ApproximateMessageCount -ne 0){$qb+=1;break}}}

        #Check for the presence of tables in the storage account
        $tb=0
        $tables = get-azstoragetable -Context $stg.context
        #if($tables){foreach ($t in $tables){if(!(get-aztablerow -Table $t.CloudTable)){$tb+=1;break}}}
        if($tables){$tb+=1;break}

        #Check for the presence of file shares in the storage account
        $fsb=0
        $shares = Get-AzStorageShare -Context $stg.context
        if($shares){foreach ($s in $shares){if(Get-azstoragefile -Context $stg.context -ShareName $s.Name){$fsb+=1;break}}}

        #Check for the presence of blobs in the storage account
        $cb=0
        $containers = Get-AzStorageContainer -Context $stg.context
        if($containers){foreach ($c in $containers){if(Get-azstorageblob -Container $c.Name -Context $stg.context){$cb+=1;break}}}

        #Extract the names of storage accounts without any entities into an array variable
        if($qb -eq 0 -and $tb -eq 0 -and $fsb -eq 0 -and $cb -eq 0){$emptystg+=$stg.StorageAccountName}

    }
} 
