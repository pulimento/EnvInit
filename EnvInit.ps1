# TODO help parameter
Set-ExecutionPolicy Bypass -Scope Process -Force; <script name>

# Check admin rights
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Check-If-Installed($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# -----------------------------------------------------------------------------
# $computerName = Read-Host 'Enter New Computer Name'
# Write-Host "Renaming this computer to: " $computerName  -ForegroundColor Yellow
# Rename-Computer -NewName $computerName
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Set monitor timeout and prevent sleep while in AC Power..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Powercfg /Change monitor-timeout-ac 5
Powercfg /Change standby-timeout-ac 0
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Removing Edge Desktop Icon..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$edgeLink = $env:USERPROFILE + "\Desktop\Microsoft Edge.lnk"
Remove-Item $edgeLink
# -----------------------------------------------------------------------------
# To list all appx packages:
# Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName
Write-Host "Removing UWP Rubbish..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

$uwpRubbishApps = @(
    "Microsoft.Messaging", # SMS
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.YourPhone",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.Print3D",
    "Microsoft.Office.OneNote",
    "Microsoft.OneConnect", # Paid WiFI&Cellular
    "Microsoft.Wallet" # MSFT Pay(?)
)

$3rdPartyCrapApps = @(
    "king.com.CandyCrushSaga",
    "Fitbit.FitbitCoach",
    "DolbyLaboratories.DolbyAccess",
    "ActiproSoftwareLLC.562882FEEB491",
    "46928bounde.EclipseManager",
    "PandoraMediaInc.29680B314EFC2",
    "AdobeSystemIncorporated.AdobePhotoshop",
    "D5EA27B7.Duolingo-LearnLanguagesforFree",
    "Microsoft.NetworkSpeedTest",
    "Microsoft.Office.Sway"
)

foreach ($crap in $uwpRubbishApps) {
    Get-AppxPackage -Name $crap | Remove-AppxPackage
}

foreach ($crap in $3rdPartyCrapApps) {
    Get-AppxPackage -Name $crap | Remove-AppxPackage
}

# -----------------------------------------------------------------------------

if (Check-If-Installed -cmdname 'choco') {
    Write-Host "Choco is already installed, skip installation."
}
else {
    Write-Host ""
    Write-Host "Installing Chocolate for Windows..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

Write-Host ""
Write-Host "Installing Applications..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

if (Check-If-Installed -cmdname 'git') {
    Write-Host "Git is already installed, checking new version..."
    choco upgrade git -y
}
else {
    Write-Host ""
    Write-Host "Installing Git for Windows..." -ForegroundColor Green
    choco install git -y
}

$ChocoAppsBasic = @(
    "7zip",
    "paint.net",
    "notepadplusplus",
    "vscode"
)

$ChocoAppsMultimedia = @(
    "audacity",
    "spotify",
    "vlc",    
    "winamp"
)

$ChocoAppsDev = @(
    "git-fork",
    "kdiff3"
)

$ChocoAppsUtils = @( 
    "sharex",    
    "youtube-dl",
    "handbrake",
    "sysinternals"
)

# SUGGESTIONS (I personally prefer to install it manually):
# - Microsoft Teams
# - Microsoft Visual Studio
# - Android Studio
# - Microsoft Office
# - JDK

function ChocoInstall($AppsList) {

    $confirmation = Read-Host "Do you want to install this app group? [$AppsList] ('y' to confirm, other key skips)"

    if ($confirmation -eq 'y') {
        foreach ($app in $AppsList) {
            choco install $app -y
        }
    } else {
        Write-Host 'Skipped'
    }
}

ChocoInstall $ChocoAppsBasic
ChocoInstall $ChocoAppsMultimedia
ChocoInstall $ChocoAppsDev
ChocoInstall $ChocoAppsUtils

# TODO install windows terminal from store, windows terminal profile, handbrake, vp9 and heic features Microsoft.HEIFImageExtension
# VSCode profile and fonts
# remove generated links on desktop
# pin icons to taskgar (possible??)
# individual app fine tuning
# git user

Write-Host "------------------------------------" -ForegroundColor Green
Read-Host -Prompt "Setup is done, restart is needed, press [ENTER] to restart computer."
Restart-Computer