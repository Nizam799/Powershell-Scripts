# This script can be used to get details of disk whther its a managed disk or unmanaged
$subs = "<" , "<subId>"

foreach($sub in $subs){
    $vms = Get-AzVM
     
    $out = @()

    foreach($vm in $vms){

        # $resourceGroupName = $vm.ResourceGroupName

        if($null -ne $vm.storageprofile.osdisk.manageddisk){
            $d = "ManagedDisk(OsDisk)"
        } else{
            $d = "UnmanagedDisk(OsDisk)"
        }
        if($null -ne $vm.storageprofile.datadisks){
            foreach($disk in $vm.storageprofile.datadisks){
                $dn = $disk.name
                $value = Get-Azdisk -ResourceGroupName $vm.ResourceGroupName -disk $dn
                if ($null -ne $value){
                    $d2 = "ManagedDisk(DataDisk)"
                } else {
                    $d2 = "UnmanagedDisk(DataDisk)"
                }
            }
        }
        $rs = [Pscustomobject]@{
            Subscription = $sub
            VmName = $vm.Name
            ResourceGroup = $vm.ResourceGroupName
            OsDiskType = $d
            DataDiskType = $d2
        }
        $out += $rs
    }

}
$excel = "C:\Users\MohammedNizamuddin\Documents\Disks.xlsx"
$out | Import-Excel -path $excel -WorksheetName "DiskInfo" -AutoSize

