
#Use this code to delete alerts on vms which are mentioned in a text file

$subscriptionID = "7572a8a8-2860-4fdb-90db-3e7a00753aa9"
Set-AzContext -Subscription $subscriptionID

$machine = Get-Content -Path "C:\Users\MohammedNizamuddin\Downloads\rmalerts.txt" # text file with vm names
#txt file contains names of VMs for which alert rules needs to be removed


foreach ($mach in $machine){
    $vm = Get-Azvm -name $mach

    $Vmrg = ($vm.ResourceGroupName)
    $Vmname = ($vm.Name)
    $ResourceId = "/subscriptions/$subscriptionID/resourceGroups/$vmrg/providers/Microsoft.Compute/virtualMachines/$Vmname"

    $output = Get-AzMetricAlertRuleV2 | Where-Object {$_.Scopes -eq $ResourceId}
    foreach ($Alert in $output){
        $Alertname = ($Alert.Name)
        write-host "$Alertname"
        $rg = $Alert.resourcegroup
        Write-Host "$rg"

        try {
          Remove-AzMetricAlertRuleV2 -Name $Alertname -ResourceGroupName $rg
          Write-Host "$Alertname Alert on $vmname removed"
        }
        catch {
          write-host "$Alertname Alert was not removed"
        }

    }
  
  
  
}
