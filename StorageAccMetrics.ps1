$agname="backup_alert"
$agrg ="myrg"
$agsub="<subID>" #subID for action group
$action = [Microsoft.Azure.Management.Monitor.Management.Models.ActivityLogAlertActionGroup]::New("/subscriptions/$agsub/resourceGroups/$agrg/providers/microsoft.insights/actiongroups/$agname")
$action
Setting up condition as object
$condition1 = New-AzMetricAlertRuleV2Criteria `
 -MetricName "Availability" `
 -MetricNameSpace "Microsoft.storage/storageAccounts" `
 -TimeAggregation Average `
 -Operator LessThan `
 -Threshold 90


$condition4 = New-AzMetricAlertRuleV2Criteria `
 -MetricName "Successe2eLatency" `
 -MetricNameSpace "Microsoft.storage/storageAccounts" `
 -TimeAggregation Average `
 -Operator GreaterThan `
 -Threshold 90

$condition5 = New-AzMetricAlertRuleV2Criteria `
 -MetricName "SuccessServerLatency" `
 -MetricNameSpace "Microsoft.storage/storageAccounts" `
 -TimeAggregation Average `
 -Operator GreaterThan `
 -Threshold 90

 $condition6 = New-AzMetricAlertRuleV2Criteria `
 -MetricName "Usedcapacity" `
 -MetricNameSpace "Microsoft.storage/storageAccounts" `
 -TimeAggregation Average `
 -Operator GreaterThan `
 -Threshold 90

$subscriptionID = "subID" #subID 

Set-AzContext -Subscription $subscriptionID
$ClientName = "Nizam"
 
$accounts = Get-AzStorageAccount
foreach ($acc in $accounts){
 $AccName = ($acc.StorageAccountName)
 $resourceGroupName = $acc.ResourceGroupName
 
 $unit = 0
 $threshold = 0
 switch ($acc.kind) {
   "storage" {
     $threshold = 1048576
     $unit = "Bytes"
   }
   "StorageV2" {
     $threshold = 1048576
     $unit = "Bytes"
   }
   "BlobStorage" {
     $threshold = 1.84
     $unit = MiB
   }
 }
 
 $value = 1929379.84
 $condition2 = New-AzMetricAlertRuleV2Criteria `
  -MetricName "Egress" `
  -MetricNameSpace "Microsoft.storage/storageAccounts" `
  -TimeAggregation Average `
  -Operator GreaterThan `
  -Threshold $value
  -Unit $unit

 $condition3 = New-AzMetricAlertRuleV2Criteria `
  -MetricName "Ingress" `
  -MetricNameSpace "Microsoft.storage/storageAccounts" `
  -TimeAggregation Average `
  -Operator GreaterThan `
  -Threshold $threshold
  -Unit "MiB"


 $rg = Get-AzResourceGroup -Name "Storage-account-alerts-RG"
 $rg1 = ($rg.ResourceGroupName)
 $Location = ($acc.location)

 write-host "$Location"
  
 Write-Host "creating alert rule on $AccName"
 Add-AzMetricAlertRuleV2 `
    -Name "$ClientName - StorageAccount - $AccName - Availability - Critical" `
    -ResourceGroupName $rg1 `
    -WindowSize 0:15 `
    -Frequency 0:15 `
    -TargetResourceScope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.storage/storageAccounts/$AccName" `
    -TargetResourceType "Microsoft.storage/storageAccounts" `
    -TargetResourceRegion $Location `
    -Description "Triggers when the availability of a service drops below a specified threshold, indicating potential outages or downtime." `
    -Severity 0 `
    -ActionGroup $action `
    -Condition $condition1
 

 Add-AzMetricAlertRuleV2 `
    -Name "$ClientName - StorageAccount - $AccName - Egress - High" `
    -ResourceGroupName $rg1 `
    -WindowSize 0:30 `
    -Frequency 0:15 `
    -TargetResourceScope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.storage/storageAccounts/$AccName" `
    -TargetResourceType "Microsoft.storage/storageAccounts" `
    -TargetResourceRegion $Location `
    -Description "Monitors outbound traffic from the services." `
    -Severity 1 `
    -ActionGroup $action `
    -Condition $condition2

 Add-AzMetricAlertRuleV2 `
    -Name "$ClientName - StorageAccount - $AccName - Ingress - High" `
    -ResourceGroupName $rg1 `
    -WindowSize 1:0 `
    -Frequency 0:15 `
    -TargetResourceScope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.storage/storageAccounts/$AccName" `
    -TargetResourceType "Microsoft.storage/storageAccounts" `
    -TargetResourceRegion $Location `
    -Description "Monitors inbound traffic to the services." `
    -Severity 1 `
    -ActionGroup $action `
    -Condition $condition3

 Add-AzMetricAlertRuleV2 `
    -Name "$ClientName - StorageAccount - $AccName - Success E2E Latency - High" `
    -ResourceGroupName $rg1 `
    -WindowSize 0:30 `
    -Frequency 0:15 `
    -TargetResourceScope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.storage/storageAccounts/$AccName" `
    -TargetResourceType "Microsoft.storage/storageAccounts" `
    -TargetResourceRegion $Location `
    -Description "Alerts when the time taken for a request to travel from the client to the server and back exceeds the defined threshold, indicating performance issues." `
    -Severity 1 `
    -ActionGroup $action `
    -Condition $condition4    

 Add-AzMetricAlertRuleV2 `
    -Name "$ClientName - StorageAccount - $AccName - Success Server Latency - High" `
    -ResourceGroupName $rg1 `
    -WindowSize 0:30 `
    -Frequency 0:15 `
    -TargetResourceScope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.storage/storageAccounts/$AccName" `
    -TargetResourceType "Microsoft.storage/storageAccounts" `
    -TargetResourceRegion $Location `
    -Description "Triggers when the server processing time for successful requests exceeds the defined threshold, indicating potential server performance bottlenecks." `
    -Severity 1 `
    -ActionGroup $action `
    -Condition $condition5

 Add-AzMetricAlertRuleV2 `
    -Name "$ClientName - StorageAccount - $AccName - Used capacity - Critical" `
    -ResourceGroupName $rg1 `
    -WindowSize 1:0 `
    -Frequency 0:15 `
    -TargetResourceScope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.storage/storageAccounts/$AccName" `
    -TargetResourceType "Microsoft.storage/storageAccounts" `
    -TargetResourceRegion $Location `
    -Description "Alerts when the used capacity of resources (such as CPU, memory, or storage) exceeds specified limits, indicating potential resource exhaustion or the need for scaling." `
    -Severity 0 `
    -ActionGroup $action `
    -Condition $condition6

 Write-Host "Aler Rules creation done on $AccName"
}
