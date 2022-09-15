@description('The prefix base used to name resources created.')
param resourceGroupNameBase string = 'tailspin'


var location = resourceGroup().location

var onpremNamePrefix = '${resourceGroupNameBase}-onprem-'
var hubNamePrefix = '${resourceGroupNameBase}-hub-'
var spokeNamePrefix = '${resourceGroupNameBase}-spoke-'

var tags = {
    purpose: 'MCW'
}

/* ****************************
Virtual Networks
**************************** */

resource onprem_vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
    name: '${onpremNamePrefix}vnet'
    location: location
    tags: tags
    properties: {
        addressSpace: {
            addressPrefixes: [
                '10.0.0.0/16'
            ]
        }
        subnets: [
            {
                name: 'default'
                properties: {
                    addressPrefix: '10.0.0.0/24'
                }
            }
        ]
    }
}

resource hub_vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
    name: '${hubNamePrefix}vnet'
    location: location
    tags: tags
    properties: {
        addressSpace: {
            addressPrefixes: [
                '10.1.0.0/16'
            ]
        }
        subnets: [
            {
                name: 'hub'
                properties: {
                    addressPrefix: '10.1.0.0/24'
                }
            }
        ]
    }
}

resource hub_vnet_azurebastionsubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
    name: '${hub_vnet.name}/AzureBastionSubnet'
    properties: {
        addressPrefix: '10.1.1.0/24'
    }
}

resource spoke_vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
    name: '${spokeNamePrefix}vnet'
    location: location
    tags: tags
    properties: {
        addressSpace: {
            addressPrefixes: [
                '10.2.0.0/16'
            ]
        }
        subnets: [
            {
                name: 'default'
                properties: {
                    addressPrefix: '10.2.0.0/24'
                }
            }
        ]
    }
}

/* ****************************
Virtual Network Peerings
**************************** */

resource hub_onprem_vnet_peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
    name: '${hub_vnet.name}/hub-onprem'
    properties: {
        remoteVirtualNetwork: {
            id: onprem_vnet.id
        }
        allowVirtualNetworkAccess: true
        allowForwardedTraffic: true
        remoteAddressSpace: {
            addressPrefixes: [
                '10.0.0.0/16'
            ]
        }
    }
}

resource onprem_hub_vnet_peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
    name: '${onprem_vnet.name}/onprem-hub'
    properties: {
        remoteVirtualNetwork: {
            id: hub_vnet.id
        }
        allowVirtualNetworkAccess: true
        allowForwardedTraffic: true
        remoteAddressSpace: {
            addressPrefixes: [
                '10.1.0.0/16'
            ]
        }
    }
}

resource spoke_hub_vnet_peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
    name: '${spoke_vnet.name}/spoke-hub'
    properties: {
        remoteVirtualNetwork: {
            id: hub_vnet.id
        }
        allowVirtualNetworkAccess: true
        allowForwardedTraffic: true
        remoteAddressSpace: {
            addressPrefixes: [
                '10.1.0.0/16'
            ]
        }
    }
}

/* ****************************
Azure Bastion
**************************** */

resource hub_bastion 'Microsoft.Network/bastionHosts@2020-11-01' = {
    name: '${hubNamePrefix}bastion'
    location: location
    tags: tags
    sku: {
        name: 'Basic'
    }
    properties: {
        ipConfigurations: [
            {
                name: 'IpConf'
                properties: {
                    privateIPAllocationMethod: 'Dynamic'
                    publicIPAddress: {
                        id: hub_bastion_public_ip.id
                    }
                    subnet: {
                        id: hub_vnet_azurebastionsubnet.id
                    }
                }
            }
        ]
    }

}

resource hub_bastion_public_ip 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
    name: '${hubNamePrefix}bastion-pip'
    location: location
    tags: tags
    sku: {
        name: 'Standard'
        tier: 'Regional'
    }
    properties: {
        publicIPAddressVersion: 'IPv4'
        publicIPAllocationMethod: 'Static'
    }
}
