<#
Description: This script displays the VMs which dont have any tags on them
	Type:			Report
	Report:			No Tags
	Output:			CSV File/Local Computer
	Scope:			All VMs
	Subscription:	All Subscriptions
#>

#CSV file used to store the report contents
[String]$opfile = Read-host "Enter the location of desired .CSV output file"

#Remove output file if it already exists.
Remove-Item $opfile -ErrorAction SilentlyContinue

#Login to Azure
Login-AzAccount > $null

#Common variables - Do NOT change
$outarray = @()

#Navigate through every subscription
foreach ($sub in ((get-azsubscription).Name))
{
#Change the subscription context
set-azcontext -Subscription $sub > $null

#Get list of all resource groups
$resourcegroups = (get-azresourcegroup).ResourceGroupName

#Navigate through every resource group
foreach ($rg in $resourcegroups)
{
#Get list of all virtual machines
$vms = Get-AzVM -ResourceGroupName $rg

	foreach ($vm in $vms)
    {
		$c = ($vm.tags).Count
		#Resource contains tags
		if ($c -eq 0)
		{
			$outarray += New-Object PsObject -property @{
			'Subscription' = [String]$sub
			'ResourceGroupName' = [String]$rg
			'ResourceName' = [String]$vm.Name
														}
		}
	}
}
}
    
$outarray | Export-Csv -Path $opfile -NoTypeInformation
