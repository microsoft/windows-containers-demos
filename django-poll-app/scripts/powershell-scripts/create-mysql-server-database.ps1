# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

Foreach ($i in $(Get-Content variables.txt)){Set-Variable -Name $i.split("=")[0] -Value $i.split("=",2)[1]}

$subscriptionId = (az account show | ConvertFrom-Json).id
$tenantId = (az account show | ConvertFrom-Json).tenantId

# Set Azure subscription name
Write-Host "Setting Azure subscription to $subscriptionName"  -ForegroundColor Yellow
az account set --subscription=$subscriptionName

$mysqlRgExists = az group exists --name $resourceGroupName

Write-Host "$resourceGroupName exists : $mysqlRgExists"

if ($mysqlRgExists -eq $false) {

    # Create resource group name
    Write-Host "Creating resource group $resourceGroupName in region $resourceGroupLocaltion" -ForegroundColor Yellow
    az group create `
        --name=$resourceGroupName `
        --location=$resourceGroupLocaltion `
        --output=jsonc
}

$mysqlserver = az mysql server show `
				--name $mysqlServerName `
				--resource-group $resourceGroupName `
				--query name | ConvertFrom-Json

$mysqlserverExists = $mysqlserver.Length -gt 0

if ($mysqlserverExists -eq $false) {
	# Create MySQL Server
    Write-Host "Creating MySQL Server $mysqlServerName with resource group $resourceGroupName in region $resourceGroupLocaltion" -ForegroundColor Yellow
	az mysql server create `
		--location $resourceGroupLocaltion `
		--resource-group $resourceGroupName `
		--name $mysqlServerName `
		--admin-user $mysqlServerAdminUser `
		--admin-password $mysqlServerAdminUserPassword `
		--public all `
                --sku-name $mysqlskuname `
                --ssl-enforcement Disabled `
                --storage-size $mysqlstoragesize `
		--output=jsonc
}

$mysqlDatabase = az mysql db show `
				--name $mysqlDatabaseName `
				--resource-group $resourceGroupName `
				--server $mysqlServerName `
				--query name | ConvertFrom-Json
				
$mysqlDatabaseExists = $mysqlDatabase.Length -gt 0

if ($mysqlDatabaseExists -eq $false) {
	# Create MySQL Server
    Write-Host "Creating MySQL Database $mysqlDatabaseName with resource group $resourceGroupName in region $resourceGroupLocaltion" -ForegroundColor Yellow
	
	az mysql db create `
	--name $mysqlDatabaseName `
	--resource-group $resourceGroupName `
	--server $mysqlServerName `
	--output=jsonc
	
	$mysqlDatabase = az mysql db show `
				--name $mysqlDatabaseName `
				--resource-group $resourceGroupName `
				--server $mysqlServerName `
				--query name | ConvertFrom-Json
				
	$mysqlDatabaseExists = $mysqlDatabase.Length -gt 0
	
	if ($mysqlDatabaseExists -eq $false) {
		Write-Host "Error occured while creating MySQL Database" -ForegroundColor Green
	}else{
		Write-Host "Successfully created MySQL Database" -ForegroundColor Green
	}
	
	
}