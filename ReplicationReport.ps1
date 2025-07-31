
#Use this code for getting a detailed Replication report on VMs

$subs = "<sub1>" , "<sub2>"
$out = @()
foreach($sub in $subs){
    Set-azcontext -SubscriptionId $sub

    $allvaults = Get-AzRecoveryServicesVault    #use -name "<vaultname>" for particular vaults details
    foreach($vault in $allvaults){
     Set-AzRecoveryServicesAsrVaultContext -vault $vault

     $fabrics = Get-AzRecoveryServicesAsrFabric

        foreach ($fabric in $fabrics) {
            $containers = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $fabric

         foreach ($container in $containers) {
            $items = Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $container
            foreach ($item in $items) {
                $ar = [PSCustomObject]@{
                    VMName                        = $item.FriendlyName
                    ProtectionStatus              = $item.ProtectionState
                    ReplicationHealth             = $item.ReplicationHealth
                    ReplicationHealthErrors       = ($item.ReplicationHealthErrors -join ', ')
                    RecoveryAzureVMName           = $item.RecoveryAzureVMName
                    RecoveryAzureVMSize           = $item.RecoveryAzureVMSize
                    PrimaryLocation               = $item.PrimaryFabricFriendlyName
                    RecoveryLocation              = $item.RecoveryFabricFriendlyName
                    LastSuccessfulTestFailover    = $item.LastSuccessfulTestFailoverTime
                    PolicyFriendlyName            = $item.PolicyFriendlyName
                    ReplicationProvider           = $item.ReplicationProvider
                    TestFailoverState             = $item.TestFailoverState
                    TestFailoverStateDescription  = $item.TestFailoverStateDescription
                    TfoAzureVMName                = $item.TfoAzureVMName
                    ActiveLocation                = $item.ActiveLocation
                    AllowedOperations             = ($item.AllowedOperations -join ', ')
                }

                $out += $ar
            }

         }
        }
    }
}
$path = "C:\Users\MohammedNizamuddin\Downloads\ReplicationReport.xlsx"
$out | Export-Excel -path $path -AutoSize -WorksheetName "Replication"