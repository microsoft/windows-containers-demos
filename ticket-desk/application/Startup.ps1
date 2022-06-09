.\Set-WebConfigSettings.ps1 -webConfig c:\inetpub\wwwroot\Web.config
#.\add_certificate_IIS.ps1
#C:\ServiceMonitor.exe w3svc

If (Test-Path Env:\ASPNET_ENVIRONMENT)
{
    \WebConfigTransformRunner.1.0.0.1\Tools\WebConfigTransformRunner.exe \inetpub\wwwroot\Web.config "\inetpub\wwwroot\Web.$env:ASPNET_ENVIRONMENT.config" \inetpub\wwwroot\Web.config
}
Write-Host "IIS Started..."
while ($true) { Start-Sleep -Seconds 3600 }