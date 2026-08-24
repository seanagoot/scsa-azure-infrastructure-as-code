@description('Azure region for the deployment')
param location string = 'koreacentral'

@description('Environment name')
param environment string = 'Lab'

@description('VNet address space')
param vnetAddressPrefix string = '10.40.0.0/16'

@description('Application subnet address space')
param subnetAddressPrefix string = '10.40.1.0/24'

@description('Storage account naming prefix')
param storagePrefix string = 'stscsaiac'

var commonTags = {
  Company: 'SCSA'
  Environment: environment
  ManagedBy: 'Bicep'
  Project: 'Project8'
}

var storageAccountName = '${storagePrefix}${uniqueString(resourceGroup().id)}'

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-scsa-iac'
  location: location
  tags: commonTags
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-scsa-iac'
  location: location
  tags: commonTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'snet-app'
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}


resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: commonTags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

output vnetName string = vnet.name
output subnetId string = vnet.properties.subnets[0].id
output nsgName string = nsg.name
output storageAccountName string = storage.name
