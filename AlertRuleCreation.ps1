
$subscriptionID = "5e0ec067-7409-4ede-ae47-ed0926bad2ee" #action group subscriptionID

Set-AzContext -Subscription $subscriptionID

# $agname="newgg"
# $action = [Microsoft.Azure.Management.Monitor.Management.Models.ActivityLogAlertActionGroup]::New("/subscriptions/5e0ec067-7409-4ede-ae47-ed0926bad2ee/resourceGroups/DataOps/providers/microsoft.insights/actiongroups/$agname")
$agname = get-azactiongroup -name "newgg" -ResourceGroupName "FunctionApp"
$action1 = $agname.Id
$action = [Microsoft.Azure.Management.Monitor.Management.Models.ActivityLogAlertActionGroup]::New($action1)


$condition1 = New-AzMetricAlertRuleV2Criteria `
 -MetricName "Percentage CPU" `
 -MetricNameSpace "Microsoft.Compute/virtualMachines" `
 -TimeAggregation Average `
 -Operator GreaterThan `
 -Threshold 96

$condition2 = New-AzMetricAlertRuleV2Criteria `
 -MetricName "Available Memory Bytes" `
 -MetricNameSpace "Microsoft.Compute/virtualMachines" `
 -TimeAggregation Average `
 -Operator LessThan `
 -Threshold 1000000000

$condition3 = New-AzMetricAlertRuleV2Criteria `
 -MetricName "Data Disk IOPS Consumed Percentage" `
 -MetricNameSpace "Microsoft.Compute/virtualMachines" `
 -TimeAggregation Average `
 -Operator GreaterThan `
 -Threshold 95

$condition4 = New-AzMetricAlertRuleV2Criteria `
 -MetricName "OS Disk IOPS Consumed Percentage" `
 -MetricNameSpace "Microsoft.Compute/virtualMachines" `
 -TimeAggregation Average `
 -Operator GreaterThan `
 -Threshold 95

$condition5 = New-AzMetricAlertRuleV2Criteria `
 -MetricName "VmAvailabilityMetric" `
 -MetricNameSpace "Microsoft.Compute/virtualMachines" `
 -TimeAggregation Average `
 -Operator LessThan `
 -Threshold 1

$condition6 = New-AzMetricAlertRuleV2Criteria `
 -MetricName "Network In Total" `
 -MetricNameSpace "Microsoft.Compute/virtualMachines" `
 -TimeAggregation Average `
 -Operator GreaterThan `
 -Threshold 1000000000

$condition7 = New-AzMetricAlertRuleV2Criteria `
 -MetricName "Network Out Total" `
 -MetricNameSpace "Microsoft.Compute/virtualMachines" `
 -TimeAggregation Average `
 -Operator GreaterThan `
 -Threshold 1000000000

$subscriptionID = "5e0ec067-7409-4ede-ae47-ed0926bad2ee"

Set-AzContext -Subscription $subscriptionID
$ClientName = "Nizam"

$vms = Get-AzVm
foreach ($vm in $vms){
 $VMname = ($vm.Name)

 $resourceGroupName = ($vm.ResourceGroupName) 
 
 $Location = ($vm.location)


 
 Write-Host "creating alert rule on $VMname"
 Add-AzMetricAlertRuleV2 `
    -Name "$ClientName - Virtual machines - $VMname - PercentageCPU - Critical" `
    -ResourceGroupName $resourceGroupName `
    -WindowSize 0:30 `
    -Frequency 0:15 `
    -TargetResourceScope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$VMname" `
    -TargetResourceType "Microsoft.Compute/virtualMachines" `
    -TargetResourceRegion $Location `
    -Description "Action will be triggered when CPU usage is greater than Threshold" `
    -Severity 0 `
    -ActionGroup $action `
    -Condition $condition1

#creating alert rule for Available Memory bytesaction
 Add-AzMetricAlertRuleV2 `
    -Name "$ClientName - Virtual machines - $VMname - Available Memory Bytes - Critical" `
    -ResourceGroupName $resourceGroupName `
    -WindowSize 1:0 `
    -Frequency 0:30 `
    -TargetResourceScope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$VMname" `
    -TargetResourceType "Microsoft.Compute/virtualMachines" `
    -TargetResourceRegion $Location `
    -Description "Action will be triggered when Available Memory Bytes is less than Threshold" `
    -Severity 0 `
    -ActionGroup $action `
    -Condition $condition2

#creating alert rule for Data Disk IOPS Consumed Percentage
 Add-AzMetricAlertRuleV2 `
    -Name "$ClientName - Virtual machines - $VMname - Data Disk IOPS Consumed Percentage - Critical" `
    -ResourceGroupName $resourceGroupName `
    -WindowSize 0:30 `
    -Frequency 0:30 `
    -TargetResourceScope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$VMname" `
    -TargetResourceType "Microsoft.Compute/virtualMachines" `
    -TargetResourceRegion $Location `
    -Description "Action will be triggered when Data Disk IOPS usage is Greater than Threshold" `
    -Severity 0 `
    -ActionGroup $action `
    -Condition $condition3

#creating alert rule for Data Disk IOPS Consumed Percentage
 Add-AzMetricAlertRuleV2 `
    -Name "$ClientName - Virtual machines - $VMname - OS Disk IOPS Consumed Percentage - Critical" `
    -ResourceGroupName $resourceGroupName `
    -WindowSize 0:30 `
    -Frequency 0:30 `
    -TargetResourceScope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$VMname" `
    -TargetResourceType "Microsoft.Compute/virtualMachines" `
    -TargetResourceRegion $Location `
    -Description "Action will be triggered when OS Disk IOPS usage is Greater than Threshold" `
    -Severity 0 `
    -ActionGroup $action `
    -Condition $condition4

#creating alert rule
 Add-AzMetricAlertRuleV2 `
    -Name "$ClientName - Virtual machines - $VMname - VM Availability - Critical" `
    -ResourceGroupName $resourceGroupName `
    -WindowSize 0:15 `
    -Frequency 0:15 `
    -TargetResourceScope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$VMname" `
    -TargetResourceType "Microsoft.Compute/virtualMachines" `
    -TargetResourceRegion $Location `
    -Description "Action will be triggered when VM Availability is less than Threshold." `
    -Severity 0 `
    -ActionGroup $action `
    -Condition $condition5
 Write-Host "Aler Rules creation done on $VMname"

 Add-AzMetricAlertRuleV2 `
    -Name "$ClientName - Virtual machines - $VMname - NetworkIn - Error" `
    -ResourceGroupName $resourceGroupName `
    -WindowSize 0:5 `
    -Frequency 0:5 `
    -TargetResourceScope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$VMname" `
    -TargetResourceType "Microsoft.Compute/virtualMachines" `
    -TargetResourceRegion $Location `
    -Description "Action will be triggered when Network Bytes is Greater than Threshold" `
    -Severity 0 `
    -ActionGroup $action `
    -Condition $condition6

#creating alert rule for Available Memory bytesaction
 Add-AzMetricAlertRuleV2 `
    -Name "$ClientName - Virtual machines - $VMname - NetworkOut - Error" `
    -ResourceGroupName $resourceGroupName `
    -WindowSize 0:5 `
    -Frequency 0:5 `
    -TargetResourceScope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$VMname" `
    -TargetResourceType "Microsoft.Compute/virtualMachines" `
    -TargetResourceRegion $Location `
    -Description "Action will be triggered when Network Bytes is Greater than Threshold" `
    -Severity 0 `
    -ActionGroup $action `
    -Condition $condition7
 Write-Host "Aler Rules creation done on $VMname"
}
