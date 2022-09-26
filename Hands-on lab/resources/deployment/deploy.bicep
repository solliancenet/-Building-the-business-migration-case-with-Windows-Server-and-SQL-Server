@description('The prefix base used to name resources created.')
param resourceNameBase string = 'tailspin'


var location = resourceGroup().location

var onpremNamePrefix = '${resourceNameBase}-onprem-'
var hubNamePrefix = '${resourceNameBase}-hub-'
var spokeNamePrefix = '${resourceNameBase}-spoke-'

var onpremSQLVMNamePrefix = '${onpremNamePrefix}sql-'
var onpremHyperVHostVMNamePrefix = '${onpremNamePrefix}hyperv-'

var GitHubScriptRepo = 'solliancenet/Building-the-business-migration-case-with-Windows-Server-and-SQL-Server'
var GitHubScriptRepoBranch = 'lab'
var GitHubScriptRepoBranchURL = 'https://raw.githubusercontent.com/${GitHubScriptRepo}/${GitHubScriptRepoBranch}/Hands-on lab/resources/deployment/'

var HyperVHostConfigArchiveFileName = 'create-vm.zip'
var HyperVHostConfigArchiveScriptName = 'create-vm.ps1'
var HyperVHostConfigURL = '${GitHubScriptRepoBranchURL}onprem/${HyperVHostConfigArchiveFileName}'

var HyperVHostInstallHyperVScriptFolder = '.'
var HyperVHostInstallHyperVScriptFileName = 'install-hyper-v.ps1'
var HyperVHostInstallHyperVURL = '${GitHubScriptRepoBranchURL}onprem/${HyperVHostInstallHyperVScriptFileName}'

var SQLVMConfigFileName = 'sql-vm-config.zip'
var SQLVMConfigScriptName = 'sql-vm-config.ps1'
var SQLVMConfigURL = '${GitHubScriptRepoBranchURL}onprem/${SQLVMConfigFileName}'

var labUsername = 'demouser'
var labPassword = 'demo!pass123'

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
            {
                name: 'AzureBastionSubnet'
                properties: {
                    addressPrefix: '10.1.1.0/24'
                }
            }
        ]
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
                        id: '${hub_vnet.id}/subnets/AzureBastionSubnet'
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

/* ****************************
On-premises Hyper-V Host VM
**************************** */

resource onprem_hyperv_nic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
    name: '${onpremHyperVHostVMNamePrefix}nic'
    location: location
    tags: tags
    properties: {
        ipConfigurations: [
            {
                name: 'ipconfig1'
                properties: {
                    subnet: {
                        id: '${onprem_vnet.id}/subnets/default'
                    }
                    privateIPAllocationMethod: 'Dynamic'
                }
            }
        ]
        networkSecurityGroup: {
            id: onprem_hyperv_nsg.id
        }
    }
}

resource onprem_hyperv_nsg 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
    name: '${onpremHyperVHostVMNamePrefix}nsg'
    location: location
    tags: tags
    properties: {
        securityRules: [
            {
                name: 'RDP'
                properties: {
                    protocol: 'TCP'
                    sourcePortRange: '*'
                    destinationPortRange: '3389'
                    sourceAddressPrefix: '*'
                    destinationAddressPrefix: '*'
                    access: 'Allow'
                    priority: 100
                    direction: 'Inbound'
                }
            }
        ]
    }
}

resource onprem_hyperv_vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
    name: '${onpremHyperVHostVMNamePrefix}vm'
    location: location
    tags: tags
    properties: {
        hardwareProfile: {
            vmSize: 'Standard_D4s_v5'
        }
        storageProfile: {
            osDisk: {
                createOption: 'fromImage'
            }
            imageReference: {
                publisher: 'MicrosoftWindowsServer'
                offer: 'WindowsServer'
                sku: '2019-datacenter-gensecond'
                version: 'latest'
            }
        }
        networkProfile: {
            networkInterfaces: [
                {
                    id: onprem_hyperv_nic.id
                }
            ]
        }
        osProfile: {
            computerName: 'WinServer'
            adminUsername: labUsername
            adminPassword: labPassword
        }
    }
}

resource onprem_hyperv_vm_ext_installhyperv 'Microsoft.Compute/virtualMachines/extensions@2017-12-01' = {
    name: '${onprem_hyperv_vm.name}/InstallHyperV'
    location: location
    tags: tags
    dependsOn: [
        onprem_hyperv_vm
    ]
    properties: {
        publisher: 'Microsoft.Compute'
        type: 'CustomScriptExtension'
        typeHandlerVersion: '1.4'
        autoUpgradeMinorVersion: true
        settings: {
            fileUris: [
                HyperVHostInstallHyperVURL
            ]
            commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${HyperVHostInstallHyperVScriptFolder}/${HyperVHostInstallHyperVScriptFileName}'
        }
    }
}

resource onprem_hyperv_vm_ext_createvm 'Microsoft.Compute/virtualMachines/extensions@2017-12-01' = {
    name: '${onprem_hyperv_vm.name}/CreateWinServerVM'
    location: location
    tags: tags
    dependsOn: [
        onprem_hyperv_vm
        onprem_hyperv_vm_ext_installhyperv
    ]
    properties: {
        publisher: 'Microsoft.Powershell'
        type: 'DSC'
        typeHandlerVersion: '2.9'
        autoUpgradeMinorVersion: true
        settings: {
            configuration: {
                url: HyperVHostConfigURL
                script: HyperVHostConfigArchiveScriptName
                function: 'Main'
            }
        }
    }
}


/* ****************************
On-premises SQL VM
**************************** */

resource onprem_sqlvm_nic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
    name: '${onpremSQLVMNamePrefix}nic'
    location: location
    tags: tags
    properties: {
        ipConfigurations: [
            {
                name: 'ipconfig1'
                properties: {
                    subnet: {
                        id: '${onprem_vnet.id}/subnets/default'
                    }
                    privateIPAllocationMethod: 'Dynamic'
                }
            }
        ]
        networkSecurityGroup: {
            id: onprem_sqlvm_nsg.id
        }
    }
}

resource onprem_sqlvm_nsg 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
    name: '${onpremSQLVMNamePrefix}nsg'
    location: location
    tags: tags
    properties: {
        securityRules: [
            {
                name: 'RDP'
                properties: {
                    protocol: 'TCP'
                    sourcePortRange: '*'
                    destinationPortRange: '3389'
                    sourceAddressPrefix: '*'
                    destinationAddressPrefix: '*'
                    access: 'Allow'
                    priority: 100
                    direction: 'Inbound'
                }
            }
        ]
    }
}

resource onprem_sqlvm_vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
    name: '${onpremSQLVMNamePrefix}vm'
    location: location
    tags: tags
    properties: {
        hardwareProfile: {
            vmSize: 'Standard_D4s_v5'
        }
        storageProfile: {
            osDisk: {
                createOption: 'fromImage'
            }
            imageReference: {
                publisher: 'MicrosoftSQLServer'
                offer: 'SQL2012SP4-WS2012R2'
                sku: 'Standard'
                version: 'latest'
            }
        }
        networkProfile: {
            networkInterfaces: [
                {
                    id: onprem_sqlvm_nic.id
                }
            ]
        }
        osProfile: {
            computerName: 'SQLServer'
            adminUsername: labUsername
            adminPassword: labPassword
        }
    }
}

resource onprem_sqlvm_vm_ext_sqlvmconfig 'Microsoft.Compute/virtualMachines/extensions@2017-12-01' = {
    name: '${onprem_sqlvm_vm.name}/SQLVMConfig'
    location: location
    tags: tags
    dependsOn: [
        onprem_sqlvm_vm
    ]
    properties: {
        publisher: 'Microsoft.Powershell'
        type: 'DSC'
        typeHandlerVersion: '2.9'
        autoUpgradeMinorVersion: true
        settings: {
            configuration: {
                url: SQLVMConfigURL
                script: SQLVMConfigScriptName
                function: 'Main'
            }
        }
    }
}
