# this file is used for creating Azure AKS Cluster with windows nodepool

# setting variables from variable file
Foreach ($i in $(Get-Content variables.txt)){Set-Variable -Name $i.split("=")[0] -Value $i.split("=",2)[1]}

$subscriptionId = (az account show | ConvertFrom-Json).id
$tenantId = (az account show | ConvertFrom-Json).tenantId

# Set Azure subscription name
Write-Host "Setting Azure subscription to $subscriptionName"  -ForegroundColor Yellow
az account set --subscription=$subscriptionName

$aksRgExists = az group exists --name $aksResourceGroupName

Write-Host "$aksResourceGroupName exists : $aksRgExists"

if ($aksRgExists -eq $false) {

    # Create resource group name
    Write-Host "Creating resource group $aksResourceGroupName in region $resourceGroupLocaltion" -ForegroundColor Yellow
    az group create `
        --name=$aksResourceGroupName `
        --location=$resourceGroupLocaltion `
        --output=jsonc
}

$aks = az aks show `
    --name $clusterName `
    --resource-group $aksResourceGroupName `
    --query name | ConvertFrom-Json

$aksCLusterExists = $aks.Length -gt 0

if ($aksCLusterExists -eq $false) {

    # Create AKS cluster
    Write-Host "Creating AKS cluster $clusterName with resource group $aksResourceGroupName in region $resourceGroupLocaltion" -ForegroundColor Yellow
		
	az aks create `
		--resource-group=$aksResourceGroupName `
		--name=$clusterName `
		--node-count=$workerNodeCount `
		--enable-managed-identity `
		--attach-acr=$acrRegistryName `
		--kubernetes-version=$kubernetesVersion `
		--network-plugin=$networkPlugin `
		--load-balancer-sku=$loadBalancerSKU `
		--node-vm-size=$nodeVMSize `
		--generate-ssh-keys `
        --aad-server-app-id=$serverAppId `
		--aad-server-app-secret=$serverAppSecret `
		--aad-client-app-id=$clientAppId `
        --enable-cluster-autoscaler `
        --auto-upgrade-channel="stable" `
        --min-count=$nodeMinCount `
        --max-count=$nodeMaxCount `
        --network-policy="calico" `
		--aad-tenant-id=$tenantId `
		--output=jsonc
		
	az aks nodepool add `
		--resource-group=$aksResourceGroupName `
		--cluster-name=$clusterName `
		--os-type="Windows" `
		--name=$winNodePoolName `
		--node-vm-size=$winNodeVMSize `
		--node-count=$winWorkerNodeCount `
        --enable-cluster-autoscaler `
        --min-count=$nodeMinCount `
        --max-count=$nodeMaxCount ` 

}
# Get credentials for newly created cluster
Write-Host "Getting credentials for cluster $clusterName" -ForegroundColor Yellow
az aks get-credentials `
    --resource-group=$aksResourceGroupName `
    --name=$clusterName `
	--admin `
    --overwrite-existing

Write-Host "Successfully created cluster $clusterName with $workerNodeCount node(s)" -ForegroundColor Green

Write-Host "Creating cluster role binding for Kubernetes dashboard" -ForegroundColor Green

kubectl create clusterrolebinding kubernetes-dashboard `
    -n kube-system `
    --clusterrole=cluster-admin `
    --serviceaccount=kube-system:kubernetes-dashboard