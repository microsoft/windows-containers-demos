# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
# src: https://docs.microsoft.com/en-us/azure/aks/azure-files-volume

# 1) Create Fileshare on Azure Storage Account

# 2) Save the Storage Account Key to a Kubernetes Secret

# Get storage account key
# setting variables from variable file
Foreach ($i in $(Get-Content variables.txt)){Set-Variable -Name $i.split("=")[0] -Value $i.split("=",2)[1]}

$STORAGE_KEY=$(az storage account keys list --resource-group $resourceGroupName --account-name $aksStorageAccountname --query "[0].value" -o tsv)

kubectl create secret generic azure-secret-fshare --from-literal=azurestorageaccountname=$aksStorageAccountname --from-literal=azurestorageaccountkey=$STORAGE_KEY

# 3) Deploy the PV, PVC and sample Pod:
#kubectl apply -f .