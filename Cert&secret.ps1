
$spcred = Get-AutomationPSCredential -Name "AppCredentials"

$tenant = "927d51f7-0f22-40f7-b6f4-a1f1bd89b967"

Connect-MgGraph -TenantId $tenant -Credential $spcred


Write-Output " "
Write-Output " "

$userId = "itops@mhainc.com" 
$to = "itops@mhainc.com" 
$Cc = "clouddesk@snp.com"

$DateToday = Get-Date
$Duration=100; 
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

            Key ID: $($passcred.keyId)
            
            
            "

            
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

            Certificate ID: $($certificate.keyId)
            
            "      
                

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

$Enterprise= Get-MgServicePrincipal -All

foreach($Entapp in $Enterprise){
    $Ent = $Entapp.PasswordCredentials
    if($Ent.count -gt 0){

        foreach($Entcred in $Ent){
            $ExpiryDate = $Entcred.endDateTime
            $DaysRemaining = (New-TimeSpan -Start $DateToday -End $ExpiryDate).Days
            
            if ($DaysRemaining -lt $Duration -and $DaysRemaining -ge 0){
                Write-Output "Display name: $($Entapp.displayName)"
                Write-Output "Days left:  $DaysRemaining "
                Write-Output "End date time: $($ExpiryDate)"
                Write-Output "Type: Enterprise App Certificate/Credential/Secret"

                $subject3 = "Certificate/Credential Expiring for $($Entapp.displayName)"
                $body3 = "Hi Team, 

                A Certificate/Credential is expiring from Enterprise Applications in $($DaysRemaining) Days.

                Display Name: $($Entapp.displayName)

                Expiration Date: $ExpiryDate

                App ID: $($Entapp.appId)

                Key/Certificate ID: $($Entcred.keyId) 
                
                
                 
                    "

                $message = @{
                    subject = $subject3
                    body = @{
                        contentType = "Text"
                        content = $body3
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
}


