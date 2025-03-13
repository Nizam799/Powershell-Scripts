#This script can be used to remove action groups from alert rules

$path = "C:\Users\MohammedNizamuddin\Documents\Action.xlsx"
$all = Import-Excel -path $path

$sub = "<subID>"
set-azcontext -subscriptionid $sub
$groups = ("cloud managed services" , "alertsgroup") #mention the action group names which should be removed from alerts
foreach($rule in $all){
    $name = $rule.AlertName
    $rg2 = $rule.ResourceGroupName
    $metric = Get-AzMetricAlertRuleV2 -Name $name -ResourceGroupName $rg2
    $mets = $metric.actions.ActionGroupId
    # $cnt = $mets.count
    $newv = @()
    foreach($met in $mets){
        $a1 = $met -split '/' | Select-Object -Last 1
        if ($groups -notcontains $a1){
            $g1 = [Microsoft.Azure.Management.Monitor.Management.Models.ActivityLogAlertActionGroup]::New($met)
            $newv += $g1
        }
    }
    try {
        Add-AzMetricAlertRuleV2 `
            -Name $metric.Name `
            -ResourceGroupName $metric.resourceGroup `
            -WindowSize $metric.WindowSize `
            -Frequency $metric.EvaluationFrequency `
            -TargetResourceScope $metric.Scopes `
            -TargetResourceType $metric.TargetResourceType `
            -TargetResourceRegion $metric.Location `
            -Description $metric.Description `
            -Severity $metric.Severity `
            -ActionGroup $newv `
            -Condition $metric.Criteria
    } catch {
        Write-Host "An error occurred:" -ForegroundColor Red
        Write-Host "Exception type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
        Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Stack Trace: $($_.Exception.StackTrace)" -ForegroundColor Red
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        Write-Host "Reason Phrase: $($_.Exception.Response.ReasonPhrase)" -ForegroundColor Red
    }
}