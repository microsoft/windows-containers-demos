# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
#----------Create Azure Container registry---------------------

# setting variables from variable file
Foreach ($i in $(Get-Content variables.txt)){Set-Variable -Name $i.split("=")[0] -Value $i.split("=").split(" ")[1]}

# Set Azure subscription name
Write-Host "Setting Azure subscription to $subscriptionName"  -ForegroundColor Yellow
az account set --subscription $subscriptionName

$stgRgExists = az group exists --name $resourceGroupName

Write-Host "$resourceGroupName exists : $stgRgExists"

if ($aksRgExists -eq $false) {
	#Create resource group
	Write-Host "Creating resource group $resourceGroupName in region $resourceGroupLocation" -ForegroundColor Yellow
	az group create `
		--name=$resourceGroupName `
		--location=$resourceGroupLocation `
		--output=jsonc
}

# Create a storage account
az storage account create -n $aksStorageAccountname -g $resourceGroupName -l $resourceGroupLocation --sku $aksStorageAccountSKU

# Export the connection string as an environment variable, this is used when creating the Azure file share
$AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -n $aksStorageAccountname -g $resourceGroupName -o tsv)

# Create the file share
az storage share create -n $aksFileSharename --connection-string $AZURE_STORAGE_CONNECTION_STRING

# Get storage account key
$STORAGE_KEY=$(az storage account keys list --resource-group $resourceGroupName --account-name $aksStorageAccountname --query "[0].value" -o tsv)

# Echo storage account name and key
Write-Host "Storage account name: $aksStorageAccountname" -ForegroundColor Yellow
Write-Host "Storage account key: $STORAGE_KEY" -ForegroundColor Yellow