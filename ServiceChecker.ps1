# Load the necessary .NET assemblies for MailKit and MimeKit.
# These libraries are needed for constructing and sending email messages.

Add-Type -Path "C:\Program Files\PackageManagement\NuGet\Packages\MimeKit.4.8.0\lib\netstandard2.0\MimeKit.dll"
Add-Type -Path "C:\Program Files\PackageManagement\NuGet\Packages\MailKit.4.8.0\lib\netstandard2.0\MailKit.dll"

# Create an SMTP client, message, and body builder objects.
# $SMTP will handle the connection to the SMTP server, while $Message represents the email message,
# and $Builder is used to construct the body and attachments.
$SMTP = New-Object MailKit.Net.Smtp.SmtpClient
$Message = New-Object MimeKit.MimeMessage
$Builder = New-Object MimeKit.BodyBuilder

# Import email account credentials from a secure XML file for authentication.
$Account = Import-Clixml -Path "C:\Users\V_SOI\Desktop\File Checker\gmail.xml"
#$Credentials= New-Object System.Management.Automation.PSCredential -ArgumentList $Account.UserName, $Account.Password


# Define paths for the services file and log file.
# $ServicesFilePath is the CSV file listing services to monitor,
# and $LogFilePath/$LogFile are where logs will be stored.
$ServicesFilePath = "C:\Users\V_SOI\Desktop\File Checker\Services.csv"
$LogFilePath = "C:\Users\V_SOI\Desktop\File Checker\Logs"
$LogFile = "Services $(Get-Date -Format "mm-hh-dd-MM-yyyy").txt"
# Import the list of services from the CSV file.
# This list is used to iterate over each service and check its status
$ServicesList = Import-Csv -Path $ServicesFilePath -Delimiter ","

# Iterate through each service in the CSV and check its status.
foreach ($Service in $ServicesList) {
    # Get the current status of the service specified in the CSV.
    $CurrentServiceStatus = (Get-Service -Name $Service.Name).Status
    # If the current status does not match the desired status, log and attempt to correct it.
    if (($Service.Status -ne $CurrentServiceStatus)) {
        # Log the mismatch between the current and desired status of the service.
        $Log = "Service: $($Service.Name) is currently $CurrentServiceStatus, should be $($Service.Status)"
        Write-Output $Log
        Out-File -FilePath "$LogFilePath\$LogFile" -Append -InputObject $Log

        # Attempt to set the service to the desired status and log the action.
        $Log = "Setting $($Service.Name) to $($Service.Status)"
        Set-Service -Name $Service.Name -Status $Service.Status
        # Check if the status change was successful.
        $AfterServiceStatus = (Get-Service -Name $Service.Name).Status
        if ($AfterServiceStatus -eq $Service.Status) {
            # Log a successful status change.
            $Log = "Action was successfull, service $($Service.Name) is now $AfterServiceStatus"
            Write-Output $Log
            Out-File -FilePath "$LogFilePath\$LogFile" -Append -InputObject $Log
        }
        else {
            # Log if the status change failed.
            $Log = "Action failed, service $($Service.Name) is still $AfterServiceStatus should be $($Service.Status)"
            Write-Output $Log
            Out-File -FilePath "$LogFilePath\$LogFile" -Append -InputObject $Log
        }
    }
}
# If a log file was created, send it via email.
if (Test-Path -Path "$LogFilePath\$LogFile") {
    # Configure email details: sender, recipient, subject, body, and attachment.
    $Message.From.Add("cheruiyotrodrix@gmail.com")
    $Message.To.Add("cheruiyotrodrix@gmail.com")
    $Message.Subject = "$($Env:COMPUTERNAME) is having issues with services"
    $Builder.TextBody = "Here is the log file"
    $Builder.Attachments.Add("$LogFilePath\$LogFile")
    $Message.Body = $Builder.ToMessageBody()

    # Connect to the SMTP server, authenticate, send the message, and clean up.
    $SMTP.Connect("smtp.gmail.com", 587, [MailKit.Security.SecureSocketOptions]::StartTls)
    $SMTP.Authenticate($Account.UserName, $Account.GetNetworkCredential().Password)
    $SMTP.Send($Message)
    $SMTP.Disconnect($true)
    $SMTP.Dispose()

}