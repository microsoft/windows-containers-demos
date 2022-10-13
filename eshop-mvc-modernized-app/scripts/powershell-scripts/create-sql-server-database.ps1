# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
Foreach ($i in $(Get-Content variables.txt)){Set-Variable -Name $i.split("=")[0] -Value $i.split("=").split(" ")[1]}

$subscriptionId = (az account show | ConvertFrom-Json).id
$tenantId = (az account show | ConvertFrom-Json).tenantId

# Set Azure subscription name
Write-Host "Setting Azure subscription to $subscriptionName"  -ForegroundColor Yellow
az account set --subscription $subscriptionName

$sqlRgExists = az group exists --name $resourceGroupName

Write-Host "$resourceGroupName exists : $sqlRgExists"

if ($sqlRgExists -eq $false) {

    # Create resource group name
    Write-Host "Creating resource group $resourceGroupName in region $resourceGroupLocation" -ForegroundColor Yellow
    az group create `
        --name=$resourceGroupName `
        --location=$resourceGroupLocation `
        --output=jsonc
}

$sqlserver = az sql server show `
				--name $sqlServerName `
				--resource-group $resourceGroupName `
				--query name | ConvertFrom-Json

$sqlserverExists = $sqlserver.Length -gt 0

if ($sqlserverExists -eq $false) {
	# Create SQL Server
    Write-Host "Creating SQL Server $sqlServerName with resource group $resourceGroupName in region $resourceGroupLocation" -ForegroundColor Yellow

	az sql server create `
		--name $sqlServerName `
		--resource-group $resourceGroupName `
		--location $resourceGroupLocation `
		--admin-user $sqlServerAdminUser `
		--admin-password $sqlServerAdminUserPassword `
		--output jsonc
}

$startIp="0.0.0.0"
$endIp="0.0.0.0"
az sql server firewall-rule create --resource-group $resourceGroupName --server $sqlServerName -n AllowYourIp --start-ip-address $startIp --end-ip-address $endIp

az sql server show --name $sqlServerName --resource-group $resourceGroupName

$sqlDatabase = az sql db show `
				--name $sqlDatabaseName `
				--resource-group $resourceGroupName `
				--server $sqlServerName `
				--query name | ConvertFrom-Json
				
$sqlDatabaseExists = $sqlDatabase.Length -gt 0

if ($sqlDatabaseExists -eq $false) {
	# Create SQL Server
    Write-Host "Creating SQL Database $sqlDatabaseName with resource group $resourceGroupName in region $resourceGroupLocation" -ForegroundColor Yellow
	
	az sql db create `
	--name $sqlDatabaseName `
	--resource-group $resourceGroupName `
	--server $sqlServerName `
	--edition Basic `
	--max-size 2147483648 `
	--catalog-collation SQL_Latin1_General_CP1_CI_AS `
	--collation SQL_Latin1_General_CP1_CI_AS `
	--backup-storage-redundancy Geo `
    --capacity 5 `
	--ledger-on Disabled `
	--output=jsonc
	
	$sqlDatabase = az sql db show `
				--name $sqlDatabaseName `
				--resource-group $resourceGroupName `
				--server $sqlServerName `
				--query name | ConvertFrom-Json
				
	$sqlDatabaseExists = $sqlDatabase.Length -gt 0
	
	if ($sqlDatabaseExists -eq $false) {
		Write-Host "Error occured while creating SQL Database" -ForegroundColor Green
	}else{
		Write-Host "Successfully created SQL Databas" -ForegroundColor Green
	}
	
	
}
