#This Code can be used to get notifications on expiring client secrets and certificates in app registrations

$spcred = Get-AutomationPSCredential -Name "AppCredentials"

$tenant = "<tenantID>"

Connect-MgGraph -TenantId $tenant -Credential $spcred


Write-Output " "
Write-Output " "

$userId = "itops@abc.com" 
$to = "itops@abc.com" 
$Cc = "clouddesk@abc.com"

$DateToday = Get-Date
$Duration=90; 
$appregistrations= Get-MgApplication -All

foreach ($appreg in $appregistrations) {         

    foreach ($passcred in $appreg.passwordCredentials){

        $ExpiryDate = $passcred.endDateTime
        $DaysRemaining = (New-TimeSpan -Start $DateToday -End $ExpiryDate).Days

        if ($DaysRemaining -lt $Duration -and $DaysRemaining -ge 0) {
            Write-Output "Display name: $($appreg.displayName)"
            Write-Output "Days left:  $DaysRemaining "
            Write-Output "End date time: $($passcred.endDateTime)"
            Write-Output "Type: Client Secret"

            $subject1 = "Client secret is about to expire for $($appreg.displayName)"
            $body1 = "Hello Team, 

            One of the client secret is going to expire from Azure app registrations in $($DaysRemaining) Days.

            Display Name: $($appreg.displayName) 

            Expiration Date: $($passcred.endDateTime)

            App ID: $($appreg.appId)

            Key ID: $($passcred.keyId)"

            
            $message = @{
                subject = $subject1
                body = @{
                    contentType = "Text"
                    content = $body1
                }
                toRecipients = @(@{emailAddress = @{address = $to}})
                ccRecipients = @(@{emailAddress = @{address = $Cc}})
                # saveToSentItems = $true 
            }
            # Send the email

            try {
                Send-MgUserMail -UserId $userId -Message $message
                write-output "Mail sent successfully to $to"
                Write-Output " "
                Write-Output " "
            }
            catch {
                Write-Host "An error occurred:" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Yellow
                Write-Host "Detailed error information:"
                $_ | Format-List * -Force
            }
        }
    }

    foreach ($certificate in $appreg.KeyCredentials){  

        $ExpiryDate = $certificate.endDateTime
        $DaysRemaining = (New-TimeSpan -Start $DateToday -End $ExpiryDate).Days

        if ($DaysRemaining -lt $Duration -and $DaysRemaining -ge 0) {
            Write-Output "Display name: $($appreg.displayName)"
            Write-Output "Days left:  $DaysRemaining "
            Write-Output "End date time: $($certificate.endDateTime)"
            Write-Output "Type: Certificate"

            $subject2 = "Certificate is Expiring for App Registration: $($appreg.displayName)"
            $body2 = "Hello Team, 

            A Certificate from Azure app registrations is about to expire in $($DaysRemaining) Days.

            Display Name: $($appreg.displayName) 

            Expiration Date: $($certificate.endDateTime)

            App ID: $($appreg.appId)

            Certificate ID: $($certificate.keyId)"      
                

            $message = @{
                subject = $subject2
                body = @{
                    contentType = "Text"
                    content = $body2
                }
                toRecipients = @(@{emailAddress = @{address = $to}})
                ccRecipients = @(@{emailAddress = @{address = $Cc}})
                # saveToSentItems = $true 
            }

                # Send the email

            try {
                Send-MgUserMail -UserId $userId -Message $message
                write-output "Mail sent successfully to $to"
                Write-Output " "
                Write-Output " "
            }
            catch {
                Write-Host "An error occurred:" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Yellow
                Write-Host "Detailed error information:"
                $_ | Format-List * -Force
            }
        }
    }
}