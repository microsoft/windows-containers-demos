FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019  

# Install Chocolatey
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command "$env:ChocolateyUseWindowsCompression='false'; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

# Copy files
RUN md c:\build
WORKDIR c:/build
COPY . c:/build

# Install build tools
RUN powershell Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile Nuget.exe
RUN powershell add-windowsfeature web-asp-net45 \
    && choco install microsoft-build-tools -y --allow-empty-checksums -version 14.0.23107.10 \
    && choco install dotnet4.6-targetpack --allow-empty-checksums -y \
    && nuget install MSBuild.Microsoft.VisualStudio.Web.targets -Version 14.0.0.3 \
    && nuget install WebConfigTransformRunner -Version 1.0.0.1
	
# Install LogMonitor.exe
RUN powershell New-Item -ItemType Directory C:\LogMonitor; $downloads = @( @{ uri = 'https://github.com/microsoft/windows-container-tools/releases/download/v1.1/LogMonitor.exe'; outFile = 'C:\LogMonitor\LogMonitor.exe' }, @{ uri = 'https://raw.githubusercontent.com/microsoft/iis-docker/master/windowsservercore-insider/LogMonitorConfig.json'; outFile = 'C:\LogMonitor\LogMonitorConfig.json' } ); $downloads.ForEach({ Invoke-WebRequest -UseBasicParsing -Uri $psitem.uri -OutFile $psitem.outFile })

RUN powershell remove-item C:\inetpub\wwwroot\iisstart.*

RUN xcopy .\application\src\eShopModernizedMVC\* c:\inetpub\wwwroot /s

# Enable ETW logging for Default Web Site on IIS
RUN c:\windows\system32\inetsrv\appcmd.exe set config -section:system.applicationHost/sites /"[name='Default Web Site'].logFile.logTargetW3C:"File,ETW"" /commit:apphost

# Start "C:\LogMonitor\LogMonitor.exe C:\ServiceMonitor.exe w3svc and application"

ENTRYPOINT powershell .\Startup; C:\\LogMonitor\\LogMonitor.exe ; C:\\ServiceMonitor.exe w3svc