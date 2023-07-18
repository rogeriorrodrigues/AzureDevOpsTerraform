. .\_variables.ps1

az login
az account set --subscription $SUBSCRIPTION_ID

try {
    #criacao do RESOURCE-GROUP
    if (!(az group exists -n $RESOURCE_GROUP)){
        az group create --name $RESOURCE_GROUP --location $LOCATION
    }
    az network vnet create --name $VNET --resource-group $RESOURCE_GROUP --location $LOCATION --address-prefixes 10.245.232.0/25
    az network vnet subnet create --name $SUBNET_PV --resource-group $RESOURCE_GROUP --vnet-name $VNET --address-prefixes 10.245.232.0/27
    az network vnet subnet create --name $SUBNET_APIM --resource-group $RESOURCE_GROUP --vnet-name $VNET --address-prefixes 10.245.232.32/27
    az network vnet subnet create --name $SUBNET_AGIC --resource-group $RESOURCE_GROUP --vnet-name $VNET --address-prefixes 10.245.232.64/27
    az network vnet subnet create --name $SUBNET_AKS --resource-group $RESOURCE_GROUP --vnet-name $VNET --address-prefixes 10.245.232.96/27


    #criacao da ROUTE-TABLE
    az network route-table create --name $ROUTE_TABLE_NAME --resource-group $RESOURCE_GROUP --location $LOCATION


    #criacao das rotas
    foreach ($route in $RT_ROUTES.routes){
        az network route-table route create -g $RESOURCE_GROUP --route-table-name $ROUTE_TABLE_NAME  -n $route.name `
        --next-hop-type $route.nextHopType `
        --address-prefix $route.addressPrefix `
        --next-hop-ip-address $route.nextHopIpAddress
    }

    #associar a ROUTE-TABLE nas subnetes
    az network vnet subnet update -g $RESOURCE_GROUP -n $SUBNET_PV --vnet-name $VNET --route-table $ROUTE_TABLE_NAME
    az network vnet subnet update -g $RESOURCE_GROUP -n $SUBNET_APIM --vnet-name $VNET --route-table $ROUTE_TABLE_NAME
    az network vnet subnet update -g $RESOURCE_GROUP -n $SUBNET_AGIC --vnet-name $VNET --route-table $ROUTE_TABLE_NAME
    az network vnet subnet update -g $RESOURCE_GROUP -n $SUBNET_AKS --vnet-name $VNET --route-table $ROUTE_TABLE_NAME
}
catch {
    {1:<#Do this if a terminating exception happens#>}
}
    