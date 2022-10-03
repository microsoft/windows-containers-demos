FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019

# Install Chocolatey
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command "$env:ChocolateyUseWindowsCompression='false'; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

# Install build tools
RUN powershell add-windowsfeature web-asp-net45 \
    && choco install microsoft-build-tools -y --allow-empty-checksums -version 14.0.23107.10 \
    && choco install dotnet4.6-targetpack --allow-empty-checksums -y \
    && choco install nuget.commandline --allow-empty-checksums -y \
    && nuget install MSBuild.Microsoft.VisualStudio.Web.targets -Version 14.0.0.3 \
    && nuget install WebConfigTransformRunner -Version 1.0.0.1

# Copy files
RUN md c:\build
WORKDIR c:/build
COPY . c:/build

RUN powershell remove-item C:\inetpub\wwwroot\iisstart.*

# Restore packages, build, copy
RUN powershell Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile c:/build/.nuget/nuget.exe
RUN nuget restore
RUN C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe /p:Platform="Any CPU" /p:VisualStudioVersion=12.0 /p:VSToolsPath=c:\MSBuild.Microsoft.VisualStudio.Web.targets.14.0.0.3\tools\VSToolsPath TicketDesk2.sln
RUN xcopy c:\build\TicketDesk.Web.Client\* c:\inetpub\wwwroot /s

# Start application
ENTRYPOINT ["powershell.exe", "./Startup.ps1"]