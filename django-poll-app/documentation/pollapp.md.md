## PollApp - Modernizing Python web application with Windows Container and Azure Cloud
This repository contains a sample of Django-poll web application and how to modernize it using Windows Container(Nano-server) and Azure Cloud.

## Overview
Windows Container should be used as a way to improve deployments to production, development, and test environments of existing Python applications based on different framework technologies and
deploying the Python application to the Azure Kubernetes Service.

## Goals
To containerize the Python-Django web application using Windows Container(Nano-server) and deploying it to Azure Kubernetes Service.

## Pre-requisites
- *Docker Desktop on Windows*, To create and build images of the application.
- *Azure CLI*, Azure Command-Line Interface (CLI) is a cross-platform command-line tool that can be used for windows to connect with the Azure portal and execute administrative commands on Azure resources.

## Implemented Azure Services
- Azure Container Registry (ACR)
- Azure Storage Account (file share)
- Azure Kubernetes Service (AKS)
- Azure monitoring (for logging and debugging purpose)
- Azure defender and security tool (for security purpose and scanning)
- Network Policy for CNI- Calico
- Cluster Auto Scaler
- Cluster Auto Upgrade
- Azure MySQL
- Azure key vaults (database secret)
- Azure CI/CD pipeline

## Architecture
Figure below shows the simple scenario of the original Python web application.

![image](C:\thirdapp\windows-containers-demos1\django-poll-app\documentation\overview.png)

Figure below shows the containerized Django-poll web application and deployment to a Kubernetes cluster.

![image](C:\thirdapp\windows-containers-demos1\django-poll-app\documentation\Architecture.png)

## Dockerfile for containerized Python web application

```
FROM vclick2cloud/nanoserver:1.0

RUN md c:\windows_container\Django-poll-app\application
WORKDIR c:/windows_container/Django-poll-app/application
COPY . c:/windows_container/Django-poll-app/application

RUN python -m pip install --upgrade pip
RUN pip install -r requirements.txt
RUN cmd python manage.py makemigrations

EXPOSE 8000

CMD python manage.py runserver 0.0.0.0:8000
```
We are using Nano server base image and installing requirements to build the application.

## Building Docker Image
```
docker build -t poll_app .
```
## Creating Azure Services
First create Azure Container Registry(ACR).

Open Powershell , login to Azure using command "az login".

We have created powershell scripts to create resources on Azure. Before running these script, we need to specify paramters values in *variable.txt* file.

ACR is used for storing application docker image. Follow the below path to get the script:

_C:\windows_container\Django-poll-app\scripts\powershell-scripts\create-acr.ps1_

Run above script using:

```
.\create-acr.ps1
```

## Push the custom Docker image into ACR

```
docker login <acr-container-registry>
docker tag poll_app:latest <acr-container-registry>/poll_app:latest
docker push <acr-container-registry>/poll_app:latest
```

## Create file share
File Share stores the raw data of application. Follow the below path to get the script:

_C:\windows_container\Django-poll-app\scripts\powershell-scripts\create-file-share.ps1_

Run above script using:
```
.\create-file-share.ps1
```

## Create Azure AKS Cluster
Below script creates AKS and add window's node pool that enables Cluster Autoscaling, Cluster Auto-Upgrade, Azure Monitor, Calico as a network Policy, Application Gateway to be used as the ingress of AKS cluster.

_C:\windows_container\Django-poll-app\scripts\powershell-scripts\create-aks.ps1_

Run above script using:
```
.\create-aks.ps1
```

Need to connect with AKS in order to run kubectl commands for the new cluster.

```
az aks get-credentials --resource-group=$aksResourceGroupName --name=$clusterName
```

## Create Azure MySQL database
```
C:\windows_container\Django-poll-app\scripts\powershell-scripts\create-mysql-server-database.ps1
```
Run above script using:
```
.\create-mysql-server-database.ps1
```
Run the below commands in your project directory in order to create database table:
```
python manage.py makemigrations
python manage.py migrate
```

## Create Azure Key Vault
Cluster can access this key-vault secrets and certificate, that contains connection string of MySQL server database.
```
C:\windows_container\Django-poll-app\scripts\powershell-scripts\create-key-vault.ps1
```
Assign access policy for AKS Cluster managed identity.

Open the Azure portal and perform the following steps: -
- Click on Azure-Key-Vault, go to the Access Policies and click on Add Access policy.
- Select Get from dropdown for secrets .
- Select Get from dropdown for certificate permission.
- Then click on Select Principle and search for "<clustername>-agentpool" and then click on select
- Click on ADD button.
- At last, after adding policy click on save button.

Save database connection string in Azure Key Vault. Create database secret using CLI or manually on portal.  Django poll-app application need give connection strings of database.It stored the connection string into key vault secret, such as-

On Powershell
```
$keyVaultName = "<Azure-Key-Vault-Name>"
$secret1Name = "DBHost"
$secret2Name = "DBUser"
$secret3Name = "DBPassword"
$secret4Name = "DBName"
$secret5Name = "DBPort"

az keyvault secret set --name $secret1Name --value "Your DBHost" $secret2Name --value "Your DBUser" $secret3Name --value "Your DBPassword" $secret4Name --value "Your DBName" $secret5Name --value "Your DBPort" –-vault-name $keyVaultName
```
## Implementing Azure Pipelines
Azure Pipelines automatically builds and tests code projects to make them available to others. It works with just about any language or project type. Azure Pipelines combines continuous integration (CI) and continuous delivery (CD) to test and build your code and ship it to any target.

To use Azure Pipelines, you need:
- An organization in Azure DevOps.
- To have your source code stored in a version control system.
## Building an Azure DevOps Build Pipeline
you can now create a build pipeline inside. It’s where you will create builds to perform various tasks like compiling code, bringing in dependencies and more.
- Linking a GitHub Repo to the Build Pipeline
- Using existing source code for building the pipeline
- Inspecting and Viewing the Build Pipeline in YAML
- Manually Running the Azure Build Pipeline


Check the pod and services by accessing the service external IP
```
kubectl get pods
kubectl get services
```

![image](C:\thirdapp\windows-containers-demos1\django-poll-app\documentation\1.PNG)

*You can inspect the container's file system and check the file share mounting secrets and key vault secrets.*
*You can also monitor cluster from azure portal*
