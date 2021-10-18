$Hostname = $env:COMPUTERNAME
If ($Hostname -notlike "*Tools*") {
    Write-Host "ERROR"
    Write-Host "In order for this script to correctly create the mailboxes for users (so it works with Hybrid Exchange too!), it must run on TOOLS01"
    Write-Host "Script Exiting, rerun on TOOLS01"
    Exit 1
}
else {
    try {
        Write-Host "Importing PSSession cmdlets from jlauksprdap01 exchange host"
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://jlauksprdap01.jlaltd.co.uk/powershell -Authentication Kerberos
        Import-PSSession $Session -DisableNameChecking
        Write-Host ''
    }
    catch {
        Write-Host "Failed to import PSSession commands (Exchange commands) from jlauksprdap01"
        exit 1
    }
}
$Allgroups = Get-ADGroup -filter * -Properties mail
$list =@(
"AllStaff@example.co.uk"
"AllStaff1@example24.co.uk"
)

ForEach ($Add in $list){
Clear-Variable group
$group = $allgroups | where-object {$_.mail -eq "$add"}
$dn = $Group.DistinguishedName
Write-Host "Found "$group.mail""
Write-Host ""
Update-Recipient -Identity "$dn"
}
