param (
    [Parameter(Mandatory=$true)]
    [string]$Name
)

$jsonObject = Get-Content -Path ($Name + "/config.json") | ConvertFrom-Json;
$AppDeployName = $jsonObject.AppName + "(" + $jsonObject.AppVersion + ").zip";

Copy-Item -Path "EdgeWebAppSetup.ps1" -Destination ($Name + "/EdgeWebAppSetup.ps1") -Force;

Compress-Archive -Path "$Name\*" -DestinationPath $AppDeployName -Force;