param appServicePlanName string
param functionAppName string
param keyVaultName string
param keyvaultAccessPolicies object[] = [{
  objectId: '00000000-0000-0000-0000-000000000000'
  keyPermissions: 'List'
  secretPermissions: 'List'
  certificatePermissions: 'List'
}]
@description('Location for the resources.')
param location string = resourceGroup().location

// Variables
var tenantId = subscription().tenantId

//== Get Existing Resources ==

//App Service plan (to use managed identity)
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' existing = {
  name: appServicePlanName
  scope: resourceGroup()
}

//== Resources ==
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    accessPolicies: [for accessPolicy in keyvaultAccessPolicies: {
      tenantId: tenantId
      objectId: accessPolicy.objectId
      permissions: {
        certificates: split(accessPolicy.certificatePermissions, ',')
        keys: split(accessPolicy.keyPermissions, ',')
        secrets: split(accessPolicy.secretPermissions, ',')
      }
    }]
    createMode: 'default'
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: false
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    sku: {
      family: 'A'
      name: 'standard'
    }
    softDeleteRetentionInDays: 7
  }
}

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: false
    httpsOnly: true
    siteConfig: {
      numberOfWorkers: 1
      functionAppScaleLimit: 100
      minimumElasticInstanceCount: 0
      phpVersion: 'off'
      javaVersion: null
      ftpsState: 'Disabled'
      use32BitWorkerProcess: true
      alwaysOn: true
      netFrameworkVersion: 'v7.0'
      remoteDebuggingEnabled: false
      remoteDebuggingVersion: 'VS2022'
      localMySqlEnabled: false
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      webSocketsEnabled: false
    }
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource functionApp_Settings 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'web'
  parent: functionApp
  properties: {
    appSettings: [
      {
        name: 'FUNCTIONS_EXTENSION_VERSION'
        value: '~4'
      }
      {
        name: 'FUNCTIONS_WORKER_RUNTIME'
        value: 'dotnet-isolated'
      }
      {
        name: 'WEBSITE_RUN_FROM_PACKAGE'
        value: '1'
      }
      {
        name: 'KeyVaultUri'
        value: keyVault.properties.vaultUri //'https://********.vault.azure.net/'
      }
    ]
  }
}

resource accessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        objectId: functionApp.identity.principalId
        tenantId: tenantId
        permissions: {
          keys:[
            'list'
          ]
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'list'
          ]
        }
      }
    ]
  }
}