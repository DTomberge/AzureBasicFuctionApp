using System;
using System.Reflection;
using Azure.Identity;
using DT.FunctionApp;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .ConfigureHostConfiguration(host => {
        string? keyVaultUri = Environment.GetEnvironmentVariable("KeyVaultUri");

        //Local DEV: Leave variabele KeyVaultUri empty in local.settings.json;
        //Azure: At deployment fill variable 'KeyVaultUri' with keyvault URI
        if (string.IsNullOrEmpty(keyVaultUri))
        {
            host.SetBasePath(Environment.CurrentDirectory)
            .AddJsonFile("local.settings.json")
            .AddUserSecrets(Assembly.GetExecutingAssembly(), true)
            .AddEnvironmentVariables();
        }
        else
        {
            host.AddAzureKeyVault(new Uri(keyVaultUri), new DefaultAzureCredential());
            host.AddEnvironmentVariables();
        }
    })
    .ConfigureServices((context, serviceCollection) => {
        //Read KeuVault secret via Configuration provider into DI container
        serviceCollection.Configure<MyAppConfig>(context.Configuration.GetSection("MyAppConfig"));
    })
    .Build();

host.Run();