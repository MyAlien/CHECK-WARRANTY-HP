# Get Serial and other info from BIOS
$Bios = gwmi win32_bios
$Serial = $Bios.SerialNumber

$Bios | select PSComputername, Description, BiosVersion, BuildNumber, Manufacturer, ReleaseDate, SerialNumber, Version

If (($Bios.Manufacturer -eq 'HP') -or ($Bios.Manufacturer -eq 'Hewlett-Packard')) { 
    $Msg1 = @'
    The Manufacturer is 'HP',
    Will perform the warranty check now, please wait...
'@

    $Msg2 = @'
    If you do not get the results displayed in internet explorer, 
    please try running the script a second time
'@

    Write-host -ForegroundColor Green $Msg1
    Write-host -ForegroundColor Yellow $Msg2

    # Open the Application
    $IE = New-Object -ComObject internetexplorer.application
    $IE.Navigate("https://support.hp.com/us-en/checkwarranty")


    # Ask host which country they are from
    $Country = Read-Host "What country are you from?"
    $Country
    $IE.Visible = $True

    # put the script to sleep while IE is loading
while ($IE.busy) {
         start-sleep -milliseconds 1000
    }

    # Fill in the page and send the form
    $IEDropdown = $IE.Document.IHTMLDocument3_getElementById("wFormEmailCountry_dd_headerValue")
    $IEDropdown.textContent = "$Country"
    $IEDropdown.FireEvent('onchange')
        while ($IE.busy) {
         start-sleep -Milliseconds 1000
          }

    $IESerial = $IE.Document.IHTMLDocument3_getElementById("wFormSerialNumber")
    $IESerial.value = $Serial
        while ($IE.busy) {
          start-sleep -Milliseconds 1000
          }

    $ActivateSubmitBtn = $IE.Document.IHTMLDocument3_getElementById("btnWFormSubmit")
    $ActivateSubmitBtn.disabled = $False

    $IESubmit = $IE.Document.IHTMLDocument3_getElementById("btnWFormSubmit")
    $IESubmit.click()

    }
else {
    $Msg3 = @'
    "The Manufacturer is not "HP", 
    this warranty check will now exit, 
    make sure that the client's computer is made by "HP"
'@
    write-host -ForegroundColor Magenta $Msg3
    start-sleep -Seconds 10
    exit
}