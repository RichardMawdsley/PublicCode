$CSVLocation = "LOCATION\AVON_Lote01_-_Interlagos.csv"
$LogFile = "LOCATIONTOLOGFILE.CSV"


$Log = [System.Collections.ArrayList]@()
$ImportedCSV = Import-Csv $CSVLocation

ForEach ($Line in $ImportedCSV) {

    Clear-Variable User -ErrorAction SilentlyContinue
    Clear-Variable Computer -ErrorAction SilentlyContinue
    Clear-Variable UserStatus -ErrorAction SilentlyContinue
    Clear-Variable ComputerStatus -ErrorAction SilentlyContinue


    ######### USER ##########

    # Update User Attribute
    $User = (($Line.SamAccountName).split("\"))[1]

    Write-Host "Selecting User: $User" -ForegroundColor Yellow

    # Test if attribute exists on User
    Try {        
        $Attribute = (Get-ADUser -Identity $User -Properties "extensionAttribute15").extensionAttribute15
    }
    catch {
        $UserStatus = "Attribute does not exist on the User $User.  Unable to add or change."
        Write-Host $UserStatus -ForegroundColor Red
        Continue
    }

    # Test if attribute currently has a value and clear if so  on User
    If ($Attribute.count -ge 1) {
        Write-Host "Attribute already exists for $User.  Clearing"
        Set-ADUser -Identity $User -Clear "extensionAttribute15"
    }

    # Set Attribute on User
    try {
        Set-ADUser -Identity $User -Add @{extensionAttribute15 = "VIVALDI" }
        $UserStatus = "Success"
        Write-Host $UserStatus -ForegroundColor Green
    }
    catch {
        $UserStatus = "Failed"
        Write-Host $UserStatus -ForegroundColor Red
    }


    ######### Computer ##########


    # Update Computer Attribute
    $Computer = $Line.Hostname

    Write-Host "Selecting Computer: $Computer" -ForegroundColor Yellow

    # Test if attribute exists on Computer
    Try {        
        $Attribute = (Set-ADComputer -Identity $Computer -Properties "extensionAttribute15").extensionAttribute15
    }
    catch {
        $ComputerStatus = "Attribute does not exist on the User $Computer.  Unable to add or change."
        Write-Host $ComputerStatus -ForegroundColor Red
        Continue
    }

    # Test if attribute currently has a value and clear if so  on User
    If ($Attribute.count -ge 1) {
        Write-Host "Attribute already exists for $Computer.  Clearing"
        Set-ADComputer -Identity $Computer -Clear "extensionAttribute15"
    }

    # Set Attribute on Computer
    try {
        Set-ADComputer -Identity $Computer -Add @{extensionAttribute15 = "VIVALDI" }
        $ComputerStatus = "Success"
        Write-Host $ComputerStatus -ForegroundColor Green
    }
    catch {
        $ComputerStatus = "Failed"
        Write-Host $ComputerStatus -ForegroundColor Red
    }



    # Keep record of each run
    $UserObj = [PSCustomObject]@{
        User                 = $User
        Computer             = $Computer
        ScriptUserStatus     = $UserStatus
        ScriptComputerStatus = $ComputerStatus
        OldAttributeValue    = $Attribute
    }

    [void]$Log.Add($UserObj)

}

# Finally export the results
if ($Log.Count -gt 0) {
    $Log | Export-Csv -Path $LogFile -NoTypeInformation
}

Write-Host "Log exported to $LogFile" -ForegroundColor Green
Write-Host "Complete" -ForegroundColor Green
