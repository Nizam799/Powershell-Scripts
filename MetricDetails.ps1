
$subs = "<subID>" , "<subID>"
foreach($sub in $subs){
    set-azcontext -subscriptionid $sub

    $rules = Get-AzMetricAlertRuleV2
    $res = @()
    foreach($rule in $rules){
        $name = $rule.name
        $target = $rule.scopes | foreach-object { $_ -split '/' | Select-Object -Last 1 }
        $type = $rule.scopes | ForEach-Object { ($_.split('/'))[-2] }
        $metricname = $rule.criteria.MetricName
        $threshold = $rule.criteria.threshold
        $operator = $rule.criteria.operatorproperty
        $condition = "$operator $threshold"
        $ActionGroups      = ($rule.Actions.actiongroupid | ForEach-Object {
            $_ -split '/' | Select-Object -Last 1
        }) -join ", "
        $status = $rule.Enabled
        

        $out = [PSCustomObject]@{
            RuleName = $name
            Type = $type
            ResourceName = $target
            Metric = $metricname
            Condition = $condition
            ActionGroups = $ActionGroups
            Status = $status
        }
        $res += $out
    }
}

$path = "C:\Users\MohammedNizamuddin\Documents\MHArules.xlsx"

$res | Export-excel -path $path -AutoSize -WorksheetName "Rules"