



Connect-MgGraph -TenantId $tenant -Credential $creds 
$userId = "mohammednizamuddin@snp.com"
$to = "mohammednizamuddin@snp.com"
$cc = "mdamear453@gmail.com"

$subject = "Network Bandwidth between Sql servers "
$date = Get-Date -Format "yyyy-MM-dd"

$fileName = "BandwidthReport_$(Get-Date -Format 'yyyyMMdd').xlsx"  # Path to your Excel file

# Read the file and encode it in Base64
$filePath = Join-Path $env:RUNNER_TEMP $fileName
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