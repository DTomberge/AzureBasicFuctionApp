using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace DT.FunctionApp
{
    public class DoTaskFunction
    {
        private readonly MyAppConfig _appConfig;
        private readonly ILogger _logger;

        /// <summary>
        /// Use DI (Dependency Injection) to get object with configuration values.
        /// </summary>
        /// <param name="appConfigOptions">Class with properties for the configuration fields.</param>
        /// <param name="loggerFactory">Logger.</param>
        public DoTaskFunction(IOptions<MyAppConfig> appConfigOptions, ILoggerFactory loggerFactory)
        {
            _appConfig = appConfigOptions.Value;
            _logger = loggerFactory.CreateLogger<DoTaskFunction>();
        }

        [Function("DoTaskFunction")]
        public HttpResponseData Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequestData req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            //For debug only. Do not log critical information!
            _logger.LogDebug($"Configuration value read: {_appConfig.SqlConnectionString}");

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

            response.WriteString("Welcome to Azure Functions!");

            return response;
        }
    }
}
