# Getting Started with Sitecore & Docker

Minimal Sitecore 9.3.0 XM demo solution.

## Prerequisites

1. Windows 10 Pro/Enterprise 1809 or later.
1. Docker for Windows, [latest stable](https://download.docker.com/win/stable/Docker%20Desktop%20Installer.exe).
1. [Azure Cli](https://aka.ms/installazurecliwindows) for using the Valtech Docker registry.
1. A valid Sitecore license placed in `C:\license`.
1. Visual Studio 2019 **16.5.0** or later.

## Running the solution

1. Authenticate with registry: `az acr login --name valtech`
1. Start: `docker-compose up --build`
1. Stop: `docker-compose down`
