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