<#
Description: Resource Group Tag reports
	Type:			Report
	Report:			Tags
	Output:			CSV File/Local Computer
	Scope:			All Resource Groups
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
$tkeys = @()
$tvalues = @()
$b = "None"

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
	$rgtags = (get-azresourcegroup -Name $rg).Tags
	$tkeys += $rgtags.Keys
	$tvalues += $rgtags.Values
	$c = $rgtags.Count
		#Resource group contains tags
		if ($c -ne 0)
		{
            for ($($i = 0; $j = 0); $i -lt $c -and $j -lt $c; $($i++; $j++))
               {
                   $outarray += New-Object PsObject -property @{
					'Subscription' = [String]$sub
                    'ResourceGroupName' = [String]$rg
                    'Tag Key' = $tkeys.Get($i)
                    'Tag Value' = $tvalues.Get($j)
                                                               }
                }
		}
		# Resource group doesn't contain tags
		Else
		{
         $outarray += New-Object PsObject -property @{
		'Subscription' = [String]$sub
        'ResourceGroupName' = [String]$rg
        'Tag Key' = [String]$b
        'Tag Value' = [String]$b
													}
		}
     $tkeys = @()
     $tvalues = @()
	}
}

#Export the array output to CSV file
$outarray | Export-Csv -Path $opfile -NoTypeInformation

