Write-Host "Starting deployment of Azure CSI Secret Store Provider using Helm" -ForegroundColor Yellow

helm repo add `
    csi-secrets-store-provider-azure `
    https://azure.github.io/secrets-store-csi-driver-provider-azure/charts

helm install csi-azure-driver `
    csi-secrets-store-provider-azure/csi-secrets-store-provider-azure `
	--set windows.enabled=true `
	--set secrets-store-csi-driver.windows.enabled=true `
	--set secrets-store-csi-driver.syncSecret.enabled=true
	
Write-Host "Deployment of Azure CSI Secret Store Provider using Helm completed successfully" -ForegroundColor Yellow