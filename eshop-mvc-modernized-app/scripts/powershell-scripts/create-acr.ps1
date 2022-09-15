# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
#----------Create Azure Container registry---------------------

# setting variables from variable file
Foreach ($i in $(Get-Content variables.txt)){Set-Variable -Name $i.split("=")[0] -Value $i.split("=",2)[1]}

# Set Azure subscription name
Write-Host "Setting Azure subscription to $subscriptionName"  -ForegroundColor Yellow
az account set --subscription=$subscriptionName

#check resource-group exists
$acrRgExists = az group exists --name $resourceGroupName

Write-Host "$resourceGroupName exists : " $aksRgExists

if ($acrRgExists -eq $false) {
	#Create resource group
	Write-Host "Creating resource group $resourceGroupName in region $resourceGroupLocation" -ForegroundColor Yellow
	az group create `
		--name=$resourceGroupName `
		--location=$resourceGroupLocation `
		--output=jsonc
}

#check acr-registry exists
$acr = az acr show `
    --name $acrRegistryName `
    --resource-group $resourceGroupName `
    --query name | ConvertFrom-Json

$acrRegistryExists = $acr.Length -gt 0

Write-Host "$acrRegistryName exists : " $acrRegistryExists

if ($acrRegistryExists -eq $false) {

	# Create Azure Container Registry with Basic SKU and Admin user disabled
	Write-Host "Creating Azure Container Registry $acrRegistryName under resource group $resourceGroupName " -ForegroundColor Yellow
	az acr create `
		--name=$acrRegistryName `
		--resource-group=$resourceGroupName `
		--sku=Basic `
		--admin-enabled=true `
		--output=jsonc
}

#If ACR registry is created without admin user, it can be updated usign the command
# az acr update -n $acrRegistryName --admin-enabled true