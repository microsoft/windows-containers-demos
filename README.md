# Windows Container on Azure Kubernetes Service Demo Apps 
Windows Container Demos is a collection of demo apps to show how you can modernize Windows Server applications with Windows containers and then deploy and run on Azure Kubernetes Service (AKS).

## List of Demo Apps:
1. **TicketDesk**: A legacy backoffice web apps (ASP.NET MVC) from https://github.com/NullDesk/ticketdesk/tree/ticketdesk-v2.1/TicketDesk-2, running on Windows Server 2019 Server Core containers.

2. **eShop**: A legacy backoffice web app (ASP.NET WebForms and MVC), a sample from .NET architecture: https://github.com/dotnet-architecture/eShopModernizing, running on Windows Server 2019 Server Core containers.

3. **Django poll app**: A Python app modeled after this Django-Poll-App https://github.com/devmahmud/Django-Poll-App, running on Windows Server 2019 Nano Server containers.

Under each folder of the apps, you can find the following:
- An overview of the app
- A tutorial that includes architecture diagrams and documentations
- A video that illustrates the modernization steps
- The source code

## Demonstrated Azure Services:
- Azure Kubernetes Service (AKS)
- Azure Container Registry (ACR)
- Azure key vaults (database secret,StorageConnectionString)
- Azure SQL
- Azure Storage Account (file share,blob storage)
- Azure monitoring (for logging and debugging purpose)
- Azure defender and security tool (for security purpose and scanning)
- Network Policy for CNI- Calico
- gMSA on Azure Kubernetes Service
- Cluster Auto Scaler
- Cluster Auto Upgrade


## We welcome your feedback
Please feel free to download and try them out. **Please also note these apps are developed for demo purpose only.** There is no customer support provided for these apps.

For any questions or feedback, please feel free to share at the Discussions tab. Or you can privately email us: win-containers@microsoft.com

## Have fun!



## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
