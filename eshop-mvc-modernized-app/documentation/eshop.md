## eShopModernizing - Modernizing ASP.NET Web apps with Windows Containers and Azure Cloud
This repo provides sample of legacy eShop web apps and how you can modernize it with Windows Containers and Azure Cloud.

## Overview
Windows Containers should be used as a way to improve deployments to production, development, and test environments of existing .NET applications based on .NET Framework technologies and 
Deploying the ASP.NET MVC app (eShopModernizedMVC) to the Azure Kubernetes Service.

## Goals for this walkthrough
We are containerizing the .NET Framework web apps with Windows Containers and Docker without changing its code and then Deploying this Windows Containers-based app to Azure Kubernetes Service.

## Pre-requisite on Windows machine/VM
- *Docker Desktop on Windows*, for creating and building images of application.
- *Azure CLI*, Azure Command-Line Interface (CLI) is a cross-platform command-line tool. You can use the Azure CLI for Windows to connect to Azure and execute administrative commands on Azure resources. 

## Implemented Azure Services
- Azure Kubernetes Service (AKS)	
- Azure Container Registry (ACR)	
- Azure key vaults (database secret,StorageConnectionString)	
- Azure SQL
- Azure Storage Account (file share,blob storage)
- Azure monitoring (for logging and debugging purpose)
- Azure defender and security tool (for security purpose and scanning)	
- Network Policy for CNI- Calico 
- Azure Active Directory (AAD)	
- Cluster Auto Scaler	
- Cluster Auto Upgrade

## Architecture
Figure below shows the simple scenario of the original legacy ASP.NET web application

![image](./legacy.png)

Figure below shows the containerized eShop legacy web application and deployment to a Kubernetes cluster

![image](./deployment.png)

## Containerizing existing .NET applications with Docker CLI and manually adding docker file 
This is the docker file

```
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019

# Install Chocolatey
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command "$env:ChocolateyUseWindowsCompression='false'; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"  

# Copy files
RUN md c:\build
WORKDIR c:/build
COPY . c:/build

# Install build tools
RUN powershell add-windowsfeature web-asp-net45 \
    && choco install microsoft-build-tools -y --allow-empty-checksums -version 140.23107.10 \
    && choco install dotnet4.6-targetpack --allow-empty-checksums -y \
    && nuget install MSBuild.Microsoft.VisualStudio.Web.targets -Version 14.0.0.3\
    && nuget install WebConfigTransformRunner -Version 1.0.0.1

# Delete existing files in wwwroot
RUN powershell remove-item C:\inetpub\wwwroot\iisstart.*

# Restore packages, build, copy
RUN xcopy c:\build\src\eShopModernizedMVC\* c:\inetpub\wwwroot /s

# Ensure container doesn't exit
ENTRYPOINT powershell .\Startup

```
We are using Windows Server Core Image and Installing necessary tools for building our project.

Startup PowerShell script will create an infinite loop to run the container.
This prevents the container from exiting and getting web dot config location from second script Set-Web Config settings that read environment variables and overrides configuration in Web dot config by modifying the file.

## Clone the repository

```json
git clone https://github.com/microsoft/windows-containers-demos #Working directory is D:/
cd windows-containers-demos # Current working directory is D:\windows-containers-demos 
```

## Building Docker Image
```
cd D:\windows-containers-demos\eshop-mvc-modernized-app
docker build -t eshopapp:latest  -f .\eshop.Dockerfile .
```

## Create Azure Services
Now, first create Azure Container Registry.

Open Powershell , login to Azure using command "az login".

```
D:\windows-containers-demos\eshop-mvc-modernized-app\scripts\powershell-scripts\create-acr.ps1
```

## Publish/Push your custom Docker image into Azure Container Registry
Open PowerShell , Login to Azure Container Registry

```
docker login <acr-container-registry>
docker tag eshopapp:latest <acr-container-registry>/eshopapp:latest
docker push <acr-container-registry>/eshopapp:latest
```

Now, Enable Microsoft Defender for container registries from the portal Which includes a vulnerability scanner to scan the images in Azure Container Registry registries and provide deeper visibility into your images vulnerabilities.

## Create file share and blob storage
File Share will store Applications Raw data and Blob storage will store Application's Images.

```
D:\windows-containers-demos\eshop-mvc-modernized-app\scripts\powershell-scripts\create-file-share.ps1
```
*Implementing blob storage from code side*

## Implementing Azure Active Directory Applications
For integrating AAD with Azure Kubernetes Service, we need to create a server and client app, which will be used to authenticate the users connecting to AKS through AAD.
This is the authentication part. 
For the authorization part, it will be managed by Role and Role Binding Kubernetes objects which is further explained.
```
D:\windows-containers-demos\eshop-mvc-modernized-app\scripts\powershell-scripts\create-ad-apps.ps1
```
After creation of AAD applications you will see the Server App ID, Server App Secret, Client App ID on powershell console, you have to update these values in Variables.txt file before creating Kubernetes Cluster.

## Create Azure AKS Cluster
This script will create AKS and add a window's node pool which enables Cluster Autoscaling, Cluster Auto-Upgrade, Azure Monitor, Calico as a network Policy, Application Gateway to be used as the ingress of an AKS cluster.
```
D:\windows-containers-demos\eshop-mvc-modernized-app\scripts\powershell-scripts\create-aks.ps1
```
It will ask for device login enter code.
Now Connect to AKS cluster as admin using command on connect on Portal

```
az aks get-credentials --resource-group=$aksResourceGroupName --name=$clusterName --admin 
```
then Run command kubectl get nodes ,where we can see user don't have access to cluster so
Apply role ,role binding for accessing cluster which is Authorization part for AAD 
```
cd D:\windows-containers-demos\eshop-mvc-modernized-app\scripts\deployment-scripts\role-binding-mainfest-files 
kubectl apply -f .
```
then You can access nodes, pods etc.

## Create Azure SQL database
```
D:\windows-containers-demos\eshop-mvc-modernized-app\scripts\powershell-scripts\create-sql-server-database.ps1
```
Next Query the database, using SSMS, Enter your server login.
You will get connected to Azure SQL database.
 Run the SQL script on sql query editor.
```
D:\windows-containers-demos\eshop-mvc-modernized-app\scripts\database-scripts
dbo.catalog_brand_hilo.Sequence.sql
dbo.catalog_hilo.Sequence.sql
dbo.catalog_type_hilo.Sequence.sql
```
Then Open Visual Studio IDE ,on Package Manager Console perform database Migration.
Run Enable-Migrations , Add-Migration InitialCreate ,and update-database -Verbose.
Again Back to SSMS , Run insert data SQL- Query
```
insertdata.sql
```
## Create Azure Key Vault 
Cluster can access this key-vault secrets and certificate, save secrets and certificate in key vault, secrets containing connection string of SQL Server database and storage account connection string.
```
D:\windows-containers-demos\eshop-mvc-modernized-app\scripts\powershell-scripts\create-key-vault.ps1
```
Assign access policy for AKS Cluster managed identity.

open an azure portal and perform the following steps: -
- Click on Azure-Key-Vault, go to the Access Policies and click on Add Access policy 
- Select Get from dropdown for secrets 
- Select Get from dropdown for certificate permission
- Then click on Select Principle and search for cluster name, agent pool and then click on select
- click on ADD button 
- At last, after adding policy click on save button. 

Now Create database secret, certificate secret and storage connection secret using CLI or manually on portal.

On Powershell
```
$keyVaultName = "<Azure-Key-Vault-Name>"
$secret1Name = "CatalogDBContext"
$secret2Name = "StorageConnectionString"
az keyvault secret set --name $secret1Name --value "DataSource=winaksserver.database.windows.net;UserId=test;Password=Root#123;InitialCatalog=eShopPorted " –-vault-name $keyVaultName
az keyvault secret set --name $secret2Name --value "DataSource=storageaccountconnectionstring" –-vault-name $keyVaultName
```

## Create Azure File Share Secrets
kubernetes cluster will use this  secret and storage account key that should be used with file share mounting while pod deployment.
```
D:\windows-containers-demos\eshop-mvc-modernized-app\scripts\powershell-scripts\aks-file-share-secrets.ps1
```
check Secrets
```
kubectl get secrets
```

## Install CSI Provider
We are installing CSI provider using helm chart, by default CSI secret provider install for linux nodes we have to install it for our window's node enable windows parameters.
```
D:\windows-containers-demos\eshop-mvc-modernized-app\scripts\powershell-scripts\deploy-csi-akv-provider.ps1
```
Check secret provider pods on window's node
```
kubectl get pods
```

## Deploy Application on AKS
Now we are ready to deploy application on AKS Cluster,
Apply Manifest files
- persistent-volume
- persistent-volume-claim
- secret-provider-class
- eshop-deployment

```
cd  D:\windows-containers-demos\eshop-mvc-modernized-app\scripts\deployment-scripts\app-deployment-mainfest-files 
kubectl apply -f .
```
```
kubectl get pods
```

for Azure file Share, we are creating persistent-volume and persistent-volume-claim.

for Azure key Vault we are using SecretProviderClass in which specifying secretObjects.

For pod deployment specifying replica sets, environment variable taking value from SecretProviderClass secrets, then mount azure file share to container using persistentVolumeClaim. And mounting SecretProviderClass for key-vault.

and using load balancer service for accessing deployment.


Check the pod and services by accessing the service external IP
```
kubectl get pods
kubectl get services
```


![image](./login.png)

*You can inspect the container's file system and check the file share mounting secrets and key vault secrets.*
*we can check blob storage in storage account inside container where pics container is created where application images are stored.*
