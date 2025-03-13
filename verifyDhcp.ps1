#Script to verfy DHCP is enabled or not

$ss = get-content -Path "C:\users\snp\desktop\dh.txt"

$output = @()
$username = "MHADOMAIN\MNizamuddin"
$password = ConvertTo-SecureString "AmearAmear@12345" -Asplaintext -force

$domainname = .ads.mhainc.com

function get-fqdn{
    param(
        [string]$cmname
    )
    return "$cmname.$domainname"
}
$creds = New-Object System.Management.Automation.PSCredential($username, $password)

$Script = {
    $ipconfig = ipconfig /all
    $dhcp = $ipconfig | select-string "DHCP Enabled"

    if ($dhcp) {
        $value = $dhcp -replace '.*:\s*', ''

    } else {
        $value = "DHCP status not found."
    }
    return $value

}

foreach ($s in $ss){
    $fqdn = get-fqdn -cmname $s
    $cmd = invoke-command -ComputerName $fqdn -ScriptBlock $Script -Credential $creds
    $result = [PSCustomObject]@{
                    
        Server        = $s
        DHCP          = $cmd
    }
    $output += $result
    $
}
$excelPath = "C:\Users\snp\Dhcp.xlsx"

$output | Export-Excel -Path $excelPath -AutoSize -WorksheetName "DHCP Status"
$ipconfig = ipconfig /all
$dhcp = $ipconfig | select-string "DHCP Enabled"
$value = $dhcp -replace '.*:\s*', ''
$


$groups = ("cloud managed services" , "alertsgroup")
$newv = @()
foreach($met in $mets){
    $a1 = $met -split '/' | Select-Object -Last 1
    if ($groups -notcontains $a1){
        $g1 = [Microsoft.Azure.Management.Monitor.Management.Models.ActivityLogAlertActionGroup]::New($met)
        $newv += $g1
    }
}


$index = 1
$metric.actions.ActionGroupId | ForEach-Object {
   Set-Variable -Name "Id$index" -Value $_
   $index++
}
$Id1