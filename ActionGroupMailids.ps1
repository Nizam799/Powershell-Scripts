$subscriptions = Get-AzSubscription # Either take all subscription in your tenant or take individual subscription IDs
$allsubs = $subscriptions.Id
# $allsubs = "<subID>" , "<subID>"

$outputs =@()
foreach($sub in $allsubs){
    set-azcontext -Subscriptionid $sub
    Get-azactiongroup | ForEach-Object {
        $output = [PSCustomObject]@{
            ActionGroup = $_.Name
            MailIds = ($_.EmailReceiver.emailaddress) -join ","
        }
        $outputs += $output
    }
    
}
$excelPath = "C:\Users\MohammedNizamuddin\Documents\Allmails.xlsx"

$outputs | Export-Excel -path $excelPath -Autosize -title "Mail Fetch" -WorksheetName "Mail sheet"

Write-host "Data has been exported to $excelpath"