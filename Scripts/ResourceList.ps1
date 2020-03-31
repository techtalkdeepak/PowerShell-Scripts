<#
Description: Resource List
	Type:			Report
	Report:			Resource Dump
	Output:			Excel File
	Scope:			All Subscriptions
#>

#CSV file used to store the report contents
[String]$opfile = Read-host "Enter the location of desired .xlsx output file"

#Remove output file if it already exists.
Remove-Item $opfile -ErrorAction SilentlyContinue

#Import excel module
if(!(Get-module "ImportExcel"))
{
    install-module -name importexcel -force
}

#Login to Azure
Login-AzAccount | Out-Null

#Common variables - Do NOT change$outarray = @()
$outarray = @()

$subs = Get-AzSubscription

#Loop through subscriptions
Foreach ($sub in $subs) 
{
    Select-AzSubscription -Subscription $Sub.Name | Out-Null
    
    #Get list of all resources
    $resources=get-azresource
  
    foreach ($res in $resources)
    {
        #Redirect output to array
	    $outarray += New-Object PsObject -property @{
			'Subscription' = [String]$sub.Name
            'Resource Group' = [String]$res.ResourceGroupName
            'Resource Name' = [String]$res.ResourceName
            'Resource Type' = [String]$res.ResourceType
        } 
     }    
}

#Export the array output to a CSV file

$outarray | select Subscription,'Resource Group','Resource Type','Resource Name' | export-excel -Path $opfile -WorksheetName "Azure Resources"