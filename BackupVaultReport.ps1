<#
Description:Get Backup Vault report - LRS/GRS
	Type:			Report
	Report:			Backup Vault
	Output:			CSV File/Local Computer
	Scope:			Azure VMs
	Subscription:	All Subscriptions
#>

#CSV file used to store the report contents
[String]$opfile = Read-host "Enter the location of desired .CSV output file"

#Remove output file if it already exists.
Remove-Item $opfile -ErrorAction SilentlyContinue

#Login to Azure
Login-AzAccount > $null

#Get all subscriptions
$subscriptions = (get-azsubscription).Name

#Define common variables
$outarray = @()

#Loop through all subscriptions
foreach ($sub in $subscriptions)
{
	#Change the subscription context
	set-azcontext -Subscription $sub
	
	#Get list of vaults
	$vaults = Get-AzRecoveryServicesVault
	
	#Loop through all vaults
	foreach ($v in $vaults)
    {
		#Get the redundancy type of underlying backup storage
        $bsr = (Get-AzRecoveryServicesBackupProperties -Vault $v).BackupStorageRedundancy
		
		#Get the list of Azure VMs being backed up
        $fnames = (Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -Status "Registered" -VaultId $v.ID).friendlyname
        $i=0
        if(!($fnames))
            {
            $i=0
            }
        else
            {
                foreach ($name in $fnames){$i += 1}
            }
			
		#Redirect values to array variable
        $outarray += New-Object PsObject -property @{
					'Subscription' = [String]$sub
					'Vault' = [String]$v.Name
					'ResourceGroup'=[String]$v.ResourceGroupName
					'Storage'=$bsr
					'VM Count' = $i
													}
      }
   
} 

#Redirect the output to CSV file
$outarray | Export-Csv -Path $opfile -NoTypeInformation
