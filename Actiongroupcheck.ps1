

$subscriptions = "<subID>" , "<subID>"
$results = @()
foreach($id in $subscriptions){
    $s = Get-azsubscription -SubscriptionId $id
    Set-AzContext -SubscriptionId $id
    # Write-Host "$id" 
    $vms = Get-azvm 

    foreach($vm in $vms){
        $VmName = $vm.name
        # Write-Host "$vmName"
        $rg = $vm.ResourceGroupName
        $Alerts = Get-AzMetricAlertRuleV2 | Where-Object {$_.Scopes -contains $vm.resourceid}
        ForEach($rule in $Alerts){
            $result = [PSCustomObject]@{
                ResourceGroupName = $rg
                VmName            = $vmName
                SubscriptionID    = $s.name
                Name              = $rule.Name
                ActionGroups      = ($rule.Actions.actiongroupid | ForEach-Object {
                    $_ -split '/' | Select-Object -Last 1
                }) -join ", " # Join multiple action groups with a comma
            }
            $results += $result
        }
        
    
    }
}

$excelPath = "C:\Users\MohammedNizamuddin\Documents\EriezMetrics.xlsx"
# Export the results to an Excel file
$results | Export-Excel -Path $excelPath -AutoSize -WorkSheetname "Alerts"

Write-Host "Data has been exported to $excelPath"

