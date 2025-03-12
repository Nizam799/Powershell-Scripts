
$subs = "<subID>" , "<subID>"
$out = @()
foreach($sub in $subs){
    Set-azcontext -SubscriptionId $sub

    $vaults = Get-AzRecoveryServicesVault
    foreach($vault in $vaults){
        Set-AzRecoveryServicesVaultContext -Vault $vault

        $vms = Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM"


        foreach ($vm in $vms) {
        
            $backupItems = Get-AzRecoveryServicesBackupItem -Container $vm -WorkloadType "AzureVm"
            

            foreach ($backupItem in $backupItems){
                $backupItem
                $poid = $backupitem.PolicyId

                $policy = Get-AzRecoveryServicesBackupProtectionPolicy -VaultId $vault.ID | where-object {$_.id -eq $poid}
                $ptype = $policy.policysubtype
                $ptime = $policy.schedulepolicy.schedulerunfrequency
                $pname = $policy.Name
                $psnap = $policies.SnapshotRetentionInDays

                $ar = [PSCustomObject]@{
                    Vault = $vault.Name
                    BackupItem = $vm.FriendlyName
                    PolicyName = $pname
                    Polictype = $ptype
                    RetentionDays = $psnap
                    ScheduleFrequency = $ptime
                }
                $out += $ar
            }
        }
    }
}
$out | Format-Table
# $path = "C:\Users\MohammedNizamuddin\Documents\MBackup.xlsx"
# $out | Export-Excel -path $path -AutoSize -WorksheetName "BAckup"