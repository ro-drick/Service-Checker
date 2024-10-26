Add-Type -Path "C:\Program Files\PackageManagement\NuGet\Packages\MimeKit.4.8.0\lib\netstandard2.0\MimeKit.dll"
Add-Type -Path "C:\Program Files\PackageManagement\NuGet\Packages\MailKit.4.8.0\lib\netstandard2.0\MailKit.dll"

$SMTP= New-Object MailKit.Net.Smtp.SmtpClient
$Message= New-Object MimeKit.MimeMessage
$Builder= New-Object MimeKit.BodyBuilder


$Account= Import-Clixml -Path "C:\Users\V_SOI\Desktop\File Checker\gmail.xml"
$Credentials= New-Object System.Management.Automation.PSCredential -ArgumentList $Account.UserName, $Account.Password



Import-Module .\MailModule.psm1
$MailAccount= Import-Clixml -Path .\gmail.xml
$MailPort= 587
$MailSMTPServer= "smtp.gmail.com"
$MailFrom= $MailAccount.UserName
$MailTo= "cheruiyotrodrix@gmail.com"

$ServicesFilePath= "C:\Users\V_SOI\Desktop\File Checker\Services.csv"
$LogFilePath= "C:\Users\V_SOI\Desktop\File Checker\Logs"
$LogFile= "Services $(Get-Date -Format "mm-hh-dd-MM-yyyy").txt"
$ServicesList= Import-Csv -Path $ServicesFilePath -Delimiter ","
foreach($Service in $ServicesList){
    $CurrentServiceStatus= (Get-Service -Name $Service.Name).Status
    if (($Service.Status -ne $CurrentServiceStatus)) {
        <# Action to perform if the condition is true #>
        $Log= "Service: $($Service.Name) is currently $CurrentServiceStatus, should be $($Service.Status)"
        Write-Output $Log
        Out-File -FilePath "$LogFilePath\$LogFile" -Append -InputObject $Log
        $Log= "Setting $($Service.Name) to $($Service.Status)"
        Set-Service -Name $Service.Name -Status $Service.Status
        $AfterServiceStatus= (Get-Service -Name $Service.Name).Status
        if ($AfterServiceStatus -eq $Service.Status) {
            <# Action to perform if the condition is true #>
            $Log= "Action was successfull, service $($Service.Name) is now $AfterServiceStatus"
            Write-Output $Log
            Out-File -FilePath "$LogFilePath\$LogFile" -Append -InputObject $Log
        }else {
            $Log= "Action failed, service $($Service.Name) is still $AfterServiceStatus should be $($Service.Status)"
            Write-Output $Log
            Out-File -FilePath "$LogFilePath\$LogFile" -Append -InputObject $Log
        }
    }
}

if (Test-Path -Path "$LogFilePath\$LogFile") {

    $Message.From.Add("cheruiyotrodrix@gmail.com")
    $Message.To.Add("cheruiyotrodrix@gmail.com")
    $Message.Subject= "$($Env:COMPUTERNAME) is having issues with services"
    $Builder.TextBody= "Here is the log file"
    $Message.Attachments= "$LogFilePath\$LogFile"
    $Builder.Attachments.Add("$LogFilePath\$LogFile")
    $Message.Body= $Builder.ToMessageBody()
    $SMTP.Connect("smtp.gmail.com", 587, [MailKit.Security.SecureSocketOptions]::StartTls)
    $SMTP.Authenticate($Account.UserName, $Account.GetNetworkCredential().Password)
    $SMTP.Send($Message)
    $SMTP.Disconnect($true)
    $SMTP.Dispose()

}