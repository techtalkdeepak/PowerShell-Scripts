<#
Description: List of NSGs with empty security rules
	Type:			Report
	Report:			Empty NSG's
	Output:			Console
	Subscription:	All Subscriptions
#>

#Login to Azure
Login-AzAccount > $null

#Get all subscriptions
$subscriptions = (get-azsubscription).ID

#Define common variables
$emptynsg = @()

#Loop through all subscriptions
foreach ($sub in $subscriptions)
{
	#Change the subscription context
	Select-AzSubscription -SubscriptionId $sub >> NULL
	
	foreach ($nsg in (get-aznetworksecuritygroup))
    {
        if (!($nsg.SecurityRules))
        {
           $emptynsg += $nsg.Name
        }
    }
} 
