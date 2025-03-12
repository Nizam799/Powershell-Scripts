
$subs = "<subscriptionID>"
$out = @()
foreach($sub in $subs){
    Set-azcontext -SubscriptionId $sub

    $allvaults = Get-AzRecoveryServicesVault -name "<RecoveryServiceVaultName" 
    foreach($vault in $allvaults){
        Set-AzRecoveryServicesVaultContext -Vault $vault

        $vms = Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM"


        foreach ($vm in $vms) {
        
            $backupItems = Get-AzRecoveryServicesBackupItem -Container $vm -WorkloadType "AzureVm"
            

            foreach ($backupItem in $backupItems){
                # $backupItem
                $lbs = $backupItem.LastBackupStatus
                $lbt = $backupItem.LastBackupTime
                $mach = $backupItem.VirtualMachineId | ForEach-Object{
                    $_ -split '/' | select-object -last 1 
                }
                $rg = $backupItem.VirtualMachineId | ForEach-Object { ($_.split('/'))[-5] }
                

`

                $ar = [PSCustomObject]@{
                    Vault = $vault.Name
                    BackupItem = $vm.FriendlyName
                    ResourceGroup = $rg
                    LastBackupStatus = $lbs
                    LastBackupTime = $lbt
                }
                $out += $ar
            }
        }
    }
}
$out
$path = "C:\Users\MohammedNizamuddin\Documents\ABackup.xlsx"
$out | Export-Excel -path $path -AutoSize -WorksheetName "Backup"