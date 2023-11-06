using System;

namespace DT.FunctionApp;

public class MyAppConfig
{
    /// <summary>
    /// Property for holding the local.settings or KeyVault secret value
    /// </summary>
    /// <remarks>
    /// KeyVault secret name must be of [classname]--[propertyname]
    /// => MyAppConfig.SqlConnectionString
    /// </remarks>
    public string? SqlConnectionString { get; set; }
}
