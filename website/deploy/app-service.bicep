// ============================================
// Azure App Service pour Workshop Website
// ============================================

@description('Nom de l\'App Service')
param appServiceName string = 'event-driven-workshop'

@description('Nom du App Service Plan')
param appServicePlanName string = 'asp-workshop'

@description('Localisation Azure')
param location string = resourceGroup().location

@description('SKU de l\'App Service Plan')
@allowed([
  'F1'  // Free
  'B1'  // Basic
  'S1'  // Standard
  'P1V2' // Premium V2
])
param sku string = 'B1'

@description('URL du repository GitHub')
param repoUrl string = 'https://github.com/Ch0wseth/EventDriven_Workshop'

@description('Branche GitHub')
param branch string = 'main'

// ============================================
// RESOURCES
// ============================================

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: sku
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
  tags: {
    Environment: 'Production'
    Project: 'EventDrivenWorkshop'
  }
}

// App Service (Static Site)
resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: appServiceName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts'
      alwaysOn: sku != 'F1' // Free tier doesn't support always on
      defaultDocuments: [
        'index.html'
      ]
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      httpLoggingEnabled: true
      detailedErrorLoggingEnabled: true
      appSettings: [
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '18-lts'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'false'
        }
      ]
    }
    httpsOnly: true
  }
  tags: {
    Environment: 'Production'
    Project: 'EventDrivenWorkshop'
  }
}

// Source Control (GitHub deployment)
resource sourceControl 'Microsoft.Web/sites/sourcecontrols@2022-09-01' = {
  parent: appService
  name: 'web'
  properties: {
    repoUrl: repoUrl
    branch: branch
    isManualIntegration: true
    deploymentRollbackEnabled: false
    isMercurial: false
  }
}

// ============================================
// OUTPUTS
// ============================================

@description('URL du site web')
output websiteUrl string = 'https://${appService.properties.defaultHostName}'

@description('Nom de l\'App Service')
output appServiceName string = appService.name

@description('ID de l\'App Service Plan')
output appServicePlanId string = appServicePlan.id
