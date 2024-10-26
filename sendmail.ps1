Add-Type -Path "C:\Program Files\PackageManagement\NuGet\Packages\MimeKit.4.8.0\lib\netstandard2.0\MimeKit.dll"
Add-Type -Path "C:\Program Files\PackageManagement\NuGet\Packages\MailKit.4.8.0\lib\netstandard2.0\MailKit.dll"

$SMTP= New-Object MailKit.Net.Smtp.SmtpClient
$Message= New-Object MimeKit.MimeMessage
$Builder= New-Object MimeKit.BodyBuilder


$Account= Import-Clixml -Path "C:\Users\V_SOI\Desktop\File Checker\gmail.xml"
$Credentials= New-Object System.Management.Automation.PSCredential -ArgumentList $Account.UserName, $Account.Password

$Message.From.Add("cheruiyotrodrix@gmail.com")
$Message.To.Add("cheruiyotrodrix@gmail.com")
$Message.Subject= "Test Message"
$Builder.TextBody= "This is a test message"
$Message.Body= $Builder.ToMessageBody()
$SMTP.Connect("smtp.gmail.com", 587, [MailKit.Security.SecureSocketOptions]::StartTls)
$SMTP.Authenticate($Account.UserName, $Account.GetNetworkCredential().Password)
$SMTP.Send($Message)
$SMTP.Disconnect($true)
$SMTP.Dispose()