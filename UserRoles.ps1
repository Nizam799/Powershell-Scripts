$subs = "<subid1>" , "<subid2>"
$excel=@()
foreach($sub in $subs){
    
    Set-azcontext -SubscriptionId $sub
    $resourcegrps = Get-AzResourceGroup
    foreach ($resgrp in $resourcegrps) {
        $rg = $resgrp.ResourceGroupname
        $resources = get-azresource -ResourceGroupName $rg
        foreach($res in $resources){
            $resname = $res.Name
            $restype = ($res.ResourceType -split '/')[-1]
            $roleAssignments = Get-AzRoleAssignment -Scope $res.resourceId
            foreach($role in $roleAssignments){
                $dname = $role.DisplayName
                $sgname = $role.SignInName
                $rdf = $role.RoleDefinitionName
                $ra = $role.ObjectType
                $scope = $role.Scope
                $inherited = ($role.Scope -split '/')[-2]
                $inherid = $role.Scope -split '/' | Select-Object -Last 1

                $gg=[PSCustomObject]@{
                    ResourceGroup = $rg
                    ResourceType = $restype
                    ResourceName = $resname
                    DisplayName = $dname
                    SignInName = $sgname
                    RoleDefinationName = $rdf
                    ObjectType = $ra
                    Scope = $scope
                    Inherited = $inherited
                    InheritedID = $inherid
                }
                $excel+=$gg
            }
        }


    }
}
$excel | Export-excel -path "C:\Users\mohammednizamuddin\Downloads\DRCSP.xlsx"