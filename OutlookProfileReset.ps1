# Full Local Outlook profile reset & Autodiscover force to 365 keys
# Designed for JLA \ Firewatch
# Rich Mawdsley

# Set Variables
$OutlookPath = "HKCU:\Software\Microsoft\Office\16.0\Outlook"
$IdentityPath = "HKCU:\Software\Microsoft\Office\16.0\Common\Identity"
$ConnectedWAMIdentity = "ConnectedWAMIdentity"
$ConnectedAccountWAMAad = "ConnectedAccountWAMAad"
$ADUserName = "ADUserName"
$TrustedSite = "TrustedSiteUrlForUserAgentVersionInfo"
$SignedOutADUser = "SignedOutADUser"
$SignedOutWAMUsers = "SignedOutWAMUsers"

# Add AutoDiscover and ADAL Key
try {
    Write-Host "Adding AutoDiscover keys" -ForegroundColor Yellow
    New-ItemProperty -Path "$OutlookPath\AutoDiscover" -Name "ExcludeExplicitO365Endpoint" -Value "0" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path "$OutlookPath\AutoDiscover" -Name "ExcludeHttpRedirect" -Value "1" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path "$OutlookPath\AutoDiscover" -Name "ExcludeHttpsAutoDiscoverDomain" -Value "1" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path "$OutlookPath\AutoDiscover" -Name "ExcludeHttpsRootDomain" -Value "1" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path "$OutlookPath\AutoDiscover" -Name "ExcludeLastKnownGoodURL" -Value "1" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path "$OutlookPath\AutoDiscover" -Name "ExcludeScpLookup" -Value "1" -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path "$OutlookPath\AutoDiscover" -Name "ExcludeSrvRecord" -Value "1" -PropertyType DWORD -Force | Out-Null
    Write-Host "Adding ADAL Key" -ForegroundColor Yellow
    New-ItemProperty -Path $IdentityPath -Name "DisableADALatopWAMOverride" -Value "1" -PropertyType DWORD -Force | Out-Null
}
catch {
    Write-Host "Failed to add required keys - please proceed manually" -ForegroundColor Red
}

# Retrieve Uniquie Identity
try {
    $Identity = Get-ItemPropertyValue -Path $IdentityPath -Name $ConnectedAccountWAMAad
    Write-Host "Identity Value $Identity" -ForegroundColor Yellow
    $IdentitySubPath = "$IdentityPath\Identities\$Identity" + "_ADAL"
    $ProfilePath = "$IdentityPath\Profiles\$Identity" + "_ADAL"
}
Catch {
    Write-Host "No Identity Found - You will need to manually search" -ForegroundColor Red
}

# Remove Identities
try {
    Write-Host "Removing identities" -ForegroundColor Yellow
    Remove-ItemProperty -Path "$IdentityPath" -Name $ConnectedAccountWAMAad, $ConnectedWAMIdentity, $ADUserName, $TrustedSite, $SignedOutADUser, $SignedOutWAMUsers -ErrorAction SilentlyContinue
    Remove-Item -Path "$IdentitySubPath" -Recurse
    Remove-Item -Path "$ProfilePath" -Recurse
}
Catch {
    Write-Host "Failed to Remove Identities - please proceed manually" -ForegroundColor Red
}


# Remove Outlook Profile
try {
    Write-Host "Removing Outlook Profiles" -ForegroundColor Yellow
    $Profiles = (Get-Item -Path "$OutlookPath\profiles\*").Name
    Foreach ($aprofile in $Profiles) {
        Write-Host "Removing "$aprofile"" -ForegroundColor Yellow
        $aprofile = $aprofile -replace ("HKEY_CURRENT_USER", "HKCU:")
        Remove-Item -Path "$aprofile" -Recurse
    }
    Remove-ItemProperty -Path "$OutlookPath" -Name "DefaultProfile"
}
Catch {
    Write-Host "Failed to remove Outlook Profile "$aprofile"" -ForegroundColor Red
}

# Wait for changes to take effect
Write-Host "Please wait for changes to propagate.. 30secs..." -ForegroundColor Yellow
Start-Sleep -Seconds 30
Write-Host "Reset Complete" -ForegroundColor Yellow
