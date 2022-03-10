# Install Eagle.net
# Rich Mawdsley / Ensono
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("Install", "Uninstall")]
    [string]$InstallMode
)

if ($InstallMode -eq "Install"){
try {
    Write-Host "Copying Eagle files to machine"
    Copy-Item -Path ".\Eagle.net" -Destination "C:\Program Files (x86)\QAD\Eagle.net" -Recurse -Force
    Copy-Item ".\EagleUpgradeDoneV1.txt" -Destination "C:\Program Files (x86)\QAD\Eagle.net" -Force # ConfigMgr Detection File
    Copy-Item ".\Start_Eagle.lnk" -Destination "C:\Users\Public\Desktop" -Force
    Copy-Item ".\Close_Eagle.lnk" -Destination "C:\Users\Public\Desktop" -Force
}
catch {
    Write-Host "Failed to copy files"
}
 
try {
    Write-Host "Copying Eagle files to user profile Documents"
    $Destination = 'C:\users\*\Documents\'
    Get-ChildItem $Destination | ForEach-Object { Copy-Item -Path '.\Documents\*' -Destination $_ -Force }
}
Catch {
    Write-Host "Failed to copy files to user profiles"
}
}


if ($InstallMode -eq "Uninstall"){
    try {
        Write-Host "Removing Eagle files from machine"
        Remove-Item -Path "C:\Program Files (x86)\QAD\Eagle.net" -Recurse -Force
        Remove-Item "C:\Users\Public\Desktop\Start_Eagle.lnk" -Force
        Remove-Item "C:\Users\Public\Desktop.\Close_Eagle.lnk" -Force
    }
    catch {
        Write-Host "Failed to copy files"
    }     
}
