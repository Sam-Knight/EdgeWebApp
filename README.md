# EdgeWebApp
Powershell script to deploy a Microsoft Edge Web App

## EdgeWebAppSetup.ps1
Use to create a Microsoft Edge standalone web app with icon on Desktop and Start Menu.
Use AddPopup switch to create registry key allowing popups for the app.
Should be run as administrator.

## WebAppDeploy.ps1
Use to create a zip file containing the config, icon, and setup script. This can be used in conjunction with an RMM solution to deploy the web app.

## Usage
Run `WebAppDeploy.ps1 -Name "Demo"` to create an archive containing all necessary files for deployment. Run `WebAppDeploy.ps1 -Name "Demo" -Install` to install the app directly, this should be run as administrator.
