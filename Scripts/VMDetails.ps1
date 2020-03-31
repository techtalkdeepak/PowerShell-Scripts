<#
Description: VM Details
	Type:			Report
	Report:			Virtual Machine Details
	Output:			CSV File
	Scope:			All Subscriptions
#>

#CSV file used to store the report contents
[String]$opfile = Read-host "Enter the location of desired .xlsx output file"

#Remove output file if it already exists.
Remove-Item $opfile -ErrorAction SilentlyContinue

#Login to Azure
Login-AzAccount | Out-Null

#Common variables - Do NOT change$outarray = @()
$outarray = @()

$subs = Get-AzSubscription

#Loop through subscriptions
Foreach ($sub in $subs) 
{
Select-AzSubscription -Subscription $Sub.Name | Out-Null

foreach ($rg in ((get-azresourcegroup).ResourceGroupName))
{
$vms = get-azvm -ResourceGroupName $rg
foreach ($vm in $vms)
    {
        #Availability set
        if($vm.AvailabilitySetReference.Id){$aset = (($vm.AvailabilitySetReference.Id).Split("/") | select -last 1) } else {$aset = "None"}

        #Public and Private IP addresses
        $puip = [String]@()
        $prip = [String]@()
        if($vm.NetworkProfile.NetworkInterfaces.Id.Count -gt 1)
        {
          foreach ($i in $vm.NetworkProfile.NetworkInterfaces.Id)
          {

            if((Get-AzNetworkInterface -ResourceId $i).IpConfigurations.PublicIpAddress.Id)
            {

                $x = (Get-AzPublicIpAddress -Name (((Get-AzNetworkInterface -ResourceId $i).IpConfigurations.PublicIpAddress.Id).Split("/") | select -last 1)).IpAddress
                $puip += $x + ","

            }
            $x = [String](Get-AzNetworkInterface -ResourceId $i).IpConfigurations.PrivateIpAddress
            $prip += $x + "," 
           
          }
              $publicip = $puip.TrimEnd(",")
              $privateip = $prip.TrimEnd(",")  
           
        }

        elseif ($vm.NetworkProfile.NetworkInterfaces.Id.Count -eq 1)
            {
                if((Get-AzNetworkInterface -ResourceId ($vm.NetworkProfile.NetworkInterfaces.Id)).IpConfigurations.PublicIpAddress.Id)
                {
                    $publicip = (Get-AzPublicIpAddress -Name (((Get-AzNetworkInterface -ResourceId ($vm.NetworkProfile.NetworkInterfaces.Id)).IpConfigurations.PublicIpAddress.Id).Split("/") | select -last 1)).IpAddress
                } 
                else
                {
                $publicip = "None"
                }    
                $privateip = [String](Get-AzNetworkInterface -ResourceId ($vm.NetworkProfile.NetworkInterfaces.Id)).IpConfigurations.PrivateIpAddress

            }
		
		#Boot Diagnostics Information
		if($vm.DiagnosticsProfile){$boot="Yes"}
        else{$boot="No"} 
		
        #VM Information
		$outarray += New-Object PsObject -property @{
			'Subscription' = $sub.Name
            'ResourceGroup' = $rg
            'Virtual Machine Name' = $vm.Name
            'OS Type' = $vm.StorageProfile.ImageReference.SKU
            'VM Size' = $vm.HardwareProfile.VmSize
            'Network Interfaces' = $vm.NetworkProfile.NetworkInterfaces.Count
            'Private IP' = $privateip
            'Public IP' = $publicip
            'DataDisks' = $vm.StorageProfile.DataDisks.Count
            'OS Disk Encryption' = (Get-AzVMDiskEncryptionStatus -ResourceGroupName $rg -VMName $vm.Name).OsVolumeEncrypted
            'Data Disk Encryption' = (Get-AzVMDiskEncryptionStatus -ResourceGroupName $rg -VMName $vm.Name).DataVolumesEncrypted
            'Availability Set' = $aset
			'Boot Diagnostics' = $boot
        }      
     }
}
}

#Redirect the virtual network information to excel file
$outarray | select-object Subscription,ResourceGroup,'Virtual Machine Name','OS Type','VM Size','Network Interfaces','Private IP','Public IP','DataDisks','Availability Set','OS Disk Encryption','Data Disk Encryption','Boot Diagnostics' | export-excel -Path $opfile -WorksheetName "VM Details"

