<#
Description: List of Empty KeyVaults in all subscriptions
	Type:			Report
	Report:			Recovery Services Vault
	Output:			CSV File/Local Computer
	Scope:			VMs under backup/replication
	Subscription:	All Subscriptions
#>

#CSV file used to store the report contents
[String]$opfile = Read-host "Enter the location of .CSV output file"

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
	$vaults = Get-AzRecoveryServicesVault -ErrorAction SilentlyContinue
	
	#Loop through all vaults
	if(!(vaults))
	{
	foreach ($v in $vaults)
    {
                
        #Define common variables
        $i=0
        $j=0
        $pfnames = @()

		#Get the redundancy type of underlying backup storage
        $bsr = (Get-AzRecoveryServicesBackupProperties -Vault $v).BackupStorageRedundancy
		
		#Get the list of Azure VMs being backed up in each backup container
        $fnames = (Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -Status "Registered" -VaultId $v.ID).friendlyname

        if(!($fnames))
        {
            $i=0
        }
        else
        {
            foreach ($name in $fnames){$i += 1}
        }
		
        #Set the ASR vault context	
        Set-AzRecoveryServicesAsrVaultContext -Vault $v

        #Get list of all ASR fabrics in the vault
        $fabric = Get-AzRecoveryServicesAsrFabric
		
		if(!($fabric))
        {
            $j=0
        }
		else
		{
			#Get list of all protection containers in the ASR fabric
			foreach ($f in $fabric)
			{
				$ProtectionContainers += Get-AzRecoveryServicesAsrProtectionContainer -Fabric $f
			}	

			#Get list of protected items in each protection container
			foreach ($pc in $ProtectionContainers)
			{
				$pfnames += (Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $pc).FriendlyName
			}
            if(!($pfnames))
            {
                $j=0
            }
            else
            {
                foreach ($name in $pfnames){$j += 1}
            }
        }
		#Redirect values to array variable
		if($i -eq 0 -and $j -eq 0)
		{
			$outarray += $v.Name
		}										
    } 
} 
} 

#Redirect the output to CSV file
$outarray | Export-Csv -Path $opfile -NoTypeInformation
