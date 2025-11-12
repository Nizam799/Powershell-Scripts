$appid = $env:APP_ID
$pswd = $env:SECRET_VALUE
$tenant = $env:TENANT_ID

$secPassword = ConvertTo-SecureString $pswd -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($appId, $secPassword)

Connect-AzAccount -ServicePrincipal -Tenantid $tenant -Credential $creds
$SubscriptionId = "4b9ea565-81cc-4eeb-8cb7-699075418a81"
set-azcontext -SubscriptionId $SubscriptionId

# Workspace and query setup
$ResourceGroup = "destination-nizam-rg"
$WorkspaceName = "Flowlogsworkspace"

# Get the workspace
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroup -Name $WorkspaceName
$WorkspaceId = $workspace.CustomerId.Guid
$query = @"
let vm1 = "10.1.0.5"; 
let vm2 = "10.1.0.4";

NTANetAnalytics
| where (SrcIp == vm1 and DestIp == vm2)
     or (SrcIp == vm2 and DestIp == vm1)
| where FlowIntervalStartTime > ago(30d)
| summarize
    SrcToDstBytes = sumif(BytesSrcToDest, SrcIp == vm1 and DestIp == vm2),
    DstToSrcBytes = sumif(BytesSrcToDest, SrcIp == vm2 and DestIp == vm1)
    by bin(FlowIntervalStartTime, 1h)
| extend
    TotalBytes = (SrcToDstBytes + DstToSrcBytes)
| extend
    Bandwidth_Mbps = (TotalBytes * 8.0) / (1024*1024*3600) 
| project
    Time = FlowIntervalStartTime,
    SrcToDstBytes,
    DstToSrcBytes,
    TotalBytes,
    Bandwidth_Mbps
| order by Time asc
"@

$results = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $query

$fileName = "BandwidthReport_$(Get-Date -Format 'yyyyMMdd').xlsx"  #file Name

$presentdirectory = Get-Location

$filePath = Join-Path $presentdirectory.Path $fileName
write-host "$filePath"

$results.Results | Export-Excel -Path $filePath
Write-Host "Query ran successfully"

Connect-MgGraph -TenantId $tenant -Credential $creds 
$userId = "mohammednizamuddin@snp.com"
$to = "mohammednizamuddin@snp.com"
$cc = "mdamear453@gmail.com"

$subject = "Network Bandwidth between Sql servers "
$date = Get-Date -Format "yyyy-MM-dd"


# Read the file and encode it in Base64
$fileBytes = [System.IO.File]::ReadAllBytes($filePath)
$fileBase64 = [System.Convert]::ToBase64String($fileBytes)
$body = "Hi Team,

The Network bandwidth report on the date $date between Aze-sql and flo-sql server is attached. 

Please reachout to snp if you have any queries.

Thanks,
SNP Team
"
$message = @{
  subject = $subject
  body = @{
      contentType = "Text"
      content = $body
  }
  toRecipients = @(@{emailAddress = @{address = $to}})
  ccRecipients = @(@{emailAddress = @{address = $Cc}})
  attachments = @(
        @{
          "@odata.type" = "#microsoft.graph.fileAttachment"
          name = $fileName
          contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          contentBytes = $fileBase64
        }
  )
# saveToSentItems = $true 
}
# Send the email

try {
  Send-MgUserMail -UserId $userId -Message $message
  write-output "Mail sent successfully to $to"
}
catch{
  Write-Host "An error occurred:" -ForegroundColor Red
  Write-Host $_.Exception.Message -ForegroundColor Yellow
  Write-Host "Detailed error information:"
  $_ | Format-List * -Force
}