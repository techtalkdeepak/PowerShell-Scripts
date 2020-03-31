<#
Description:This script displays the VM with the tags 
	Type:			Report
	Report:			Tags
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
#Get list of all virtual machines
$vms = Get-AzVM -ResourceGroupName $rg

	foreach ($vm in $vms)
    {
		$vtags = $vm.Tags
		$tkeys += $vtags.Keys
		$tvalues += $vtags.Values
		$c = $vtags.Count
		#Resource contains tags
		if ($c -ne 0)
		{
            for ($($i = 0; $j = 0); $i -lt $c -and $j -lt $c; $($i++; $j++))
            {
                $outarray += New-Object PsObject -property @{
				'ResourceGroupName' = [String]$rg
				'ResourceName' = [String]$vm.Name
                'Tag Key' = $tkeys.Get($i)
                'Tag Value' = $tvalues.Get($j)
                                                            }
             }
		}
		# Virtual machine doesn't contain tags
		Else
		{
			$outarray += New-Object PsObject -property @{
			'ResourceGroupName' = [String]$rg
			'ResourceName' = [String]$vm.Name
			'Tag Key' = [String]$b
			'Tag Value' = [String]$b
														}
		}
    $tkeys = @()
    $tvalues = @()
	}
}
}
    
$outarray | Export-Csv -Path $opfile -NoTypeInformation
