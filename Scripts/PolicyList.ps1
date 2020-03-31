
$c=($x.Length)-1
$outarray = @()

While($c -ge 0){

$text = $x[$c].Properties.displayName
$outarray += New-Object PsObject -property @{
			'Policy Definition' = [String]$text}

$c = $c-1

}

$outarray | export-excel -Path C:\Clients\DET\Policy.xlsx
