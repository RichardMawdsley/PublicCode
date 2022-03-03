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

#Power GUIDS:  https://docs.microsoft.com/en-us/windows/win32/power/power-policy-settings

$Schemes = @(
    "381b4222-f694-41f0-9685-ff5bb260df2e" # Balanced
    "a1841308-3541-4fab-bc81-f71556f20b4a" # Power saver
    "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" # High performance - Note last in last so its the last one set
)

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

Foreach ($Scheme in $schemes) {
    try {
        powercfg.exe /SetActive $Scheme
        $ActiveSchemeGUID = (powercfg.exe /getactivescheme).split(' ')[5, 6]
        Write-Host "Disabing all sleep display/power states in power profile $ActiveSchemeGUID"
    }
    Catch {
        Write-Host "Failed to retrieve power profile name"
    }

    ForEach ($option in $Options) {
        try {
            Write-Host "Setting timeout of $Option to 0"
            powercfg.exe /CHANGE $Option 0
        }
        Catch {
            Write-Host "Failed to change power option for $Option"
        }
    }
}

Write-Host "Power change complete"
