$Subs = (get-AzSubscription).ID

#Loop through the subscriptions to find all empty Resource Groups and store them in $EmptyRGs
ForEach ($sub in $Subs) {
Select-AzSubscription -SubscriptionId $Sub >> NULL
$AllRGs = (Get-AzResourceGroup).ResourceGroupName
$UsedRGs = (Get-AzResource | Group-Object ResourceGroupName).Name
$EmptyRGs = $AllRGs | Where-Object {$_ -notin $UsedRGs}
Write-Output $EmptyRGs
}
if($EmptyRGs)
{
    Write-Output "Here is the list:" $EmptyRGs
}else
{
     Write-Output "Not found any resource groups with no resources"
}