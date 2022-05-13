Param(
    [parameter(Mandatory = $false)]
    [string]$aksClusterName = "aksClustername",
    [parameter(Mandatory = $false)]
    [string]$serverName = "serverName"
)

Foreach ($i in $(Get-Content variables.txt)){Set-Variable -Name $i.split("=")[0] -Value $i.split("=",2)[1]}

$aksClusterName = ${clusterName}.replace('"','')
$serverName = ${server}.replace('"','')
$uri = "https://$aksClusterName.$serverName"

Write-Host "Cluster name $aksClusterName" -ForegroundColor Yellow
Write-Host "uri name $uri" -ForegroundColor Yellow

#Integrate Azure Active Directory with Azure Kubernetes Service
#Some Limitations
#Azure AD can only be enabled on Kubernetes RBAC-enabled cluster.
#Azure AD legacy integration can only be enabled during cluster creation.

#create and use an Azure AD application that acts as an endpoint for the identity requests
# Create the Azure AD application
$serverApplicationId=$(az ad app create `
    --display-name $aksClusterName `
    --identifier-uris "https://$aksClusterName.click2cloud.net" `
    --query appId -o tsv)

Write-Host "serverApplicationId  $serverApplicationId" -ForegroundColor Yellow

Write-Host "AAD Server Application ID $serverApplicationId" -ForegroundColor Yellow

# Update the application group membership claims
az ad app update --id $serverApplicationId --set groupMembershipClaims=All

#Now create a service principal for the server app using the az ad sp create command. This service principal is used to authenticate itself within the Azure platform
# Create a service principal for the Azure AD application
az ad sp create --id $serverApplicationId

# Get the service principal secret #specifiy password in credential-description
$serverApplicationSecret=$(az ad sp credential reset `
    --name $serverApplicationId `
    --credential-description "Myaks#12345" `
    --query password -o tsv)

#The Azure AD service principal needs permissions to perform the following actions:
#Read directory data
#Sign in and read user profile
az ad app permission add `
    --id $serverApplicationId `
    --api 00000003-0000-0000-c000-000000000000 `
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope 06da0dbc-49e2-44d2-8312-53f166ab848a=Scope 7ab1d382-f21e-4acd-a863-ba3e13f7da61=Role

#Finally, grant the permissions assigned in the previous step for the server application (it can be done by admin user only)
az ad app permission grant --id $serverApplicationId --api 00000003-0000-0000-c000-000000000000
az ad app permission admin-consent --id  $serverApplicationId

#The second Azure AD application is used when a user logs to the AKS cluster with the Kubernetes CLI (kubectl). This client application takes the authentication request from the user and verifies their credentials and permissions

$clientApplicationId=$(az ad app create `
    --display-name "${clusterName}Client".replace('"','') `
    --native-app `
    --reply-urls "https://${clusterName}Client".replace('"','') `
    --query appId -o tsv) 

#Create a service principal for the client application
az ad sp create --id $clientApplicationId

#Get the oAuth2 ID for the server app to allow the authentication flow between the two app
$oAuthPermissionId=$(az ad app show --id $serverApplicationId --query "oauth2Permissions[0].id" -o tsv)

#Add the permissions for the client application and server application components to use the oAuth2 communication, Then, grant permissions for the client application to communication with the server application

az ad app permission add --id $clientApplicationId --api $serverApplicationId --api-permissions ${oAuthPermissionId}=Scope
az ad app permission grant --id $clientApplicationId --api $serverApplicationId #can be grant by admin user


Write-Host "AAD Server Application ID $serverApplicationId" -ForegroundColor Yellow
Write-Host "AAD Server Application Secret $serverApplicationSecret" -ForegroundColor Yellow
Write-Host "AAD Client Application ID $clientApplicationId" -ForegroundColor Yellow
Write-Host "OAUTH Permission ID $oAuthPermissionId" -ForegroundColor Yellow