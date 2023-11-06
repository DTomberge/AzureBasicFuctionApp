# AzureBasicFuctionApp
The basic setup for an out-of-proces Azure Function with Keyvault integration.

This .net core solution shows a basic setup for an Azure Function with Keyvault integration.
The Function must run on an Azure App Service plan with Managed Identity enabled. This Identity
must be added to the KeyVault with the right access.


At creation of the Azure Function using the Visual Studio template make sure you choose '.NET 7.0 Isolated' as the Functions worker. (can also be .net core 6.0)


After creating the initial function, add the folowing NuGet packages:
- Azure.Identity
- Azure.Extensions.AspNetCore.Configuration.Secrets


When developing local, you can use the KeyVault on Azure, but you need to add your credentials 
of the account running VS to the KeyVault. This is not always wanted.


In this example, when developing localy, the UserSecrets are used for storing them.


To get the settings from the Environment variables or the KeyVault, they are read via the HostBuilderContext Configuration property.
Then via the Configure method the object is added to the default Dependency container.


<hr/>
In the Infra folder is a main.bicep file that creates the Azure Keyvault and Azure Function. Under the Infra folder 
is a parameters folder with a json parameter file. Here you need to set your own values.


To run the bicep file, you can use:
```
az deployment group create --resource-group "[resourcegroup-name]" --template-file "infra/main.bicep" --parameters "infra/parameters/main-parameters.jsonc" --name "functionapp-$(Get-Date -Format "yyyyMMdd-HHmmss")"
```

!! If you run this from your IDE (Terminal or Developer PowerShell), make sure you are logged in to 
the correct Azure tenant and subscription (use az login --tenant 'xx' & az account set --subscription '')