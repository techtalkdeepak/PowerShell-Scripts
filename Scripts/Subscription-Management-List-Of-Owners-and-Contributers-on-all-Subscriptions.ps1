#This script will identify all the users who are assigned owner or contributor role even though they are not administrators.

#Parameters

Param(

#CSV files

[String]$path1 = 'c:\Roles\roles1.csv',
[String]$path2 = 'c:\Roles\roles2.csv',
[String]$path3 = 'c:\Roles\AllSubscriptions-with-AllUsers-ContributorandOwner-Accounts.csv'

)

#Remove the CSV file if it already exists

Remove-Item $path1,$path2,$path3 -ErrorAction SilentlyContinue

#Obtain list of all subscriptions

$subscriptionlist = Get-AzureRmSubscription

# Begin loop for Subscriptions

Foreach ($sub in $subscriptionlist) 

{

#Select each subscription

Select-AzureRmSubscription -Subscription $sub.Id > $null

#Direct all the available owner and contributor roles to CSV file

get-azurermroledefinition | Where-Object {$_.Name -eq 'Owner' -or $_.Name -eq 'Contributor'} | Select-Object -Property Name | export-csv -Path $path1

#Import the CSV file to a variable

$testcsv = Import-csv -Path $path1 -header Name

#Get the current subscription name

$subcurrent = Get-azureRmcontext | select -ExpandProperty Subscription | select Name

#Begin loop for roles

foreach ($csv1 in $testcsv)

{

#Get list of non administrator users with owner and contributor roles by replacing string sname in the below command with the administrator keyword

Get-AzureRmRoleAssignment -RoleDefinitionName $csv1.Name | where-object {$_.DisplayName -notlike '*sname*'} | Select-Object SignInName,DisplayName,RoleDefinitionName | export-csv -Path $path2

Import-Csv -path $path2 | Select-Object *,@{Name='Subscription Name';Expression={$sub.Name}} | export-csv -Append -path $path3 -NoTypeInformation


} # End loop for roles


} # End loop for Subscriptions
