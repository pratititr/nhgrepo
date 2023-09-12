param location string = 'East US'
param storageAccountName string
param websiteContainerName string = '$web'
param cdnProfileName string
param cdnEndpointName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource websiteContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  name: '${storageAccount.name}/${websiteContainerName}'
  properties: {
    publicAccess: 'Container'
  }
}

resource cdnProfile 'Microsoft.Cdn/profiles@2020-09-01' = {
  name: cdnProfileName
  location: location
  sku: {
    name: 'Standard_Akamai'
  }
}

resource cdnEndpoint 'Microsoft.Cdn/profiles/endpoints@2020-09-01' = {
  name: cdnEndpointName
  parent: cdnProfile
  properties: {
    originHostHeader: storageAccount.primaryEndpoints.blob
    origins: [
      {
        name: 'blobOrigin'
        hostName: storageAccount.primaryEndpoints.blob
      }
    ]
    isHttpAllowed: false
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    contentTypesToCompress: [
      'text/html',
      'text/plain',
      'text/css',
      'application/javascript',
      'image/png',
      'image/jpeg'
    ]
  }
}

output storageAccountConnectionString string = storageAccount.primaryConnectionString
output websiteUrl string = storageAccount.primaryEndpoints.blob
output cdnEndpointUrl string = cdnEndpoint.properties.hostName
