<#
    .SYNOPSIS
    Script used to Disable sleep in the current power profile
    
    .EXAMPLE
    .\DisablePowerSleepStates.ps1

    .OUTPUTS
    N/A

    .NOTES
    Written by: Rich Mawdsley (Ensono)
    Date: 25/02/2022
#>

Write-Host "Disabing all sleep display/power states in current power profile $ActiveSchemeGUID"

try{
$ActiveSchemeGUID = (powercfg.exe /getactivescheme).split(' ')[5,6]
}
Catch
{
Write-Host "Failed to retrieve current power profile name"
}

$Options = @(
"monitor-timeout-ac"
"monitor-timeout-dc"
"disk-timeout-ac"
"disk-timeout-dc"
"standby-timeout-ac"
"standby-timeout-dc"
"hibernate-timeout-ac"
"hibernate-timeout-dc"
)

ForEach ($option in $Options){
try{
Write-Host "Setting timeout of $Option to 0"
powercfg.exe /CHANGE $Option 0
}
Catch
{
Write-Host "Failed to change power option for $Option"
}
}

Write-Host "Power change complete"
