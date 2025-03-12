

#This script Adds Action GRoup to a existing alert rule without removing the old existing action groups


$sub1 = "<subID>"
Set-azcontext -SubscriptionId $sub1 #connect to subscription in which actiongroup exists

$rg1 = "arv-prod-rit-rg" #resource groupname
$agname = "metric-alerts" #actiongroup name
$agname1 = get-azactiongroup -name $agname -ResourceGroupName $rg1
$ag1 = [Microsoft.Azure.Management.Monitor.Management.Models.ActivityLogAlertActionGroup]::New($agname1.Id)

# $sub2 = "bf663624-45a5-48bd-9854-8aaf0b95c849" 
# Set-azcontext -SubscriptionId $sub2   #connect to subscription in which alerts needs to be configured

$path = "C:\Users\MohammedNizamuddin\Documents\book3.xlsx" #importing alerts in excel from local machine 
$all = Import-Excel -path $path


foreach($alert in $all){
    $name = $alert.AlertName
    $rg2 = $alert.ResourceGroupName
    $metric = Get-AzMetricAlertRuleV2 -Name $name -ResourceGroupName $rg2
    
    $newv = @()
    $met = $metric.actions.ActionGroupId
    foreach($met in $mets){
        $g1 = [Microsoft.Azure.Management.Monitor.Management.Models.ActivityLogAlertActionGroup]::New($met)
        $newv += $g1
    }
    $newv += $ag1

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

