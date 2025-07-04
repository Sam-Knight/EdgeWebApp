param (
    [switch]$Uninstall,
    [switch]$AddPopup
)

$jsonObject = Get-Content -Path "config.json" | ConvertFrom-Json;

$AppName = $jsonObject.AppName;
$AppVersion = $jsonObject.AppVersion;
$AppDescription = $jsonObject.AppDescription;
$AppLinkPayload = $jsonObject.AppLinkPayload;
$LinkOptions = $jsonObject.LinkOptions;

$EdgeLocation = [Environment]::GetFolderPath('ProgramFilesX86') + "\Microsoft\Edge\Application\";
$AppInstallLocation = [Environment]::GetFolderPath('ProgramFiles') +"\$AppName";
$AppFullPath = "$AppInstallLocation\$AppName.lnk";
$iconLocation = "$AppInstallLocation\Icon.ico";
$iconTempLocation = "Icon.ico";
$AppArgs = "--app=$AppLinkPayload $LinkOptions";
$StartMenuLocation = [Environment]::GetFolderPath('CommonPrograms') + "\$AppDescription.lnk";
$DesktopLocation = [Environment]::GetFolderPath('CommonDesktopDirectory') + "\$AppDescription.lnk";

$PopupAllowDomain = ([System.Uri]$AppLinkPayload).Authority;
$hashBytes = [System.Security.Cryptography.MD5]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($AppName));
$PopupID = [string][BitConverter]::ToUInt16($hashBytes,0);
$RegistryLocation = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\PopupsAllowedForUrls";

$AddPopup = $true;
# Fresh Install Setup
$AppExists = Test-Path -Path $AppFullPath;

if(-not ($AppExists -or $Uninstall)){
    if(-not (Test-Path -Path $AppInstallLocation)){
        [void](New-Item -Path $AppInstallLocation -ItemType Directory);
    }
}

# Update remove old link
if($AppExists -or $Uninstall){
    Remove-Item -Path $StartMenuLocation -erroraction silentlycontinue;
    Remove-Item -Path $DesktopLocation -erroraction silentlycontinue;
    Remove-Item -Path $iconLocation -ErrorAction SilentlyContinue;
    Remove-Item -Path $AppFullPath;
}

if($Uninstall){
    Remove-Item -Path $AppInstallLocation;
        
    #Uninstall registry key
    if(Test-Path -Path $RegistryLocation){

    }

    return;
}

Copy-Item -Path $iconTempLocation -Destination $iconLocation;

# Create web app
$wshShell = New-Object -ComObject WScript.Shell;
$shortcut = $wshShell.CreateShortcut($AppFullPath);
$shortcut.TargetPath = $EdgeLocation + "msedge_proxy.exe";
$shortcut.Arguments = $AppArgs;
$shortcut.WorkingDirectory = $EdgeLocation;
$shortcut.WindowStyle = 1 # Normal window
$shortcut.Description = $AppDescription;
$shortcut.IconLocation = $iconLocation;
$shortcut.Save();

# Create a shortcut to app in Start
$wshShell = New-Object -ComObject WScript.Shell;
$shortcut2 = $wshShell.CreateShortcut($StartMenuLocation);
$shortcut2.TargetPath = $AppFullPath;
$shortcut2.WorkingDirectory = $StartMenuLocation;
$shortcut2.WindowStyle = 1 # Normal window
$shortcut2.Description = $AppDescription;
$shortcut2.IconLocation = $iconLocation;
$shortcut2.Save();

# Create a shortcut to app on desktop
$wshShell = New-Object -ComObject WScript.Shell;
$shortcut3 = $wshShell.CreateShortcut($DesktopLocation);
$shortcut3.TargetPath = $AppFullPath;
$shortcut3.WorkingDirectory = $DesktopLocation;
$shortcut3.WindowStyle = 1 # Normal window
$shortcut3.Description = $AppDescription;
$shortcut3.IconLocation = $iconLocation;
$shortcut3.Save();

if($AddPopup){
    If (-NOT (Test-Path $RegistryLocation)) {
        New-Item -Path $RegistryLocation -Force | Out-Null;
    }
    try{ Set-ItemProperty -Path $RegistryLocation -Name $PopupID -Value $PopupAllowDomain -Force  | Out-Null;}
    catch{ New-ItemProperty -Path $RegistryLocation -Name $PopupID -Value $PopupAllowDomain -PropertyType string -Force  | Out-Null; }
}