##Variaveis
$AMBIENTE="piloto"

#SPOKE
$SUBSCRIPTION="Arquitetura de Referencia de TI"
$SUBSCRIPTION_ID="279ab7a1-a977-4ef7-a192-d07bfbe6b06b"
$LOCATION="brazilsouth"
$RESOURCE_GROUP="rg-"+$AMBIENTE

$VNET="VNET-"+$AMBIENTE
$ROUTE_TABLE_NAME="RT-"+$AMBIENTE
$SUBNET_PV="subnet-pv"
$SUBNET_APIM="subnet-apim"
$SUBNET_AGIC="subnet-apgw"
$SUBNET_AKS="subnet-aks"


$RT_ROUTES = '
[
    {
        "routes": [
            {
                "addressPrefix": "10.244.37.192/28",
                "name": "'+$ROUTE_TABLE_NAME+'",
                "nextHopIpAddress": "10.245.195.68",
                "nextHopType": "VirtualAppliance"
            },
            {
                "addressPrefix": "10.244.37.128/26",
                "name": "RT-JUMP",
                "nextHopIpAddress": "10.245.195.68",
                "nextHopType": "VirtualAppliance"
            }
        ],
        "subnets": [
            {
                "name": "subnet-pv",
                "resourceGroup": "'+$RESOURCE_GROUP+'"
            },
            {
                "name": "subnet-apim",
                "resourceGroup": "'+$RESOURCE_GROUP+'"
            },
            {
                "name": "subnet-apgw",
                "resourceGroup": "'+$RESOURCE_GROUP+'"
            },
            {
                "name": "subnet-aks",
                "resourceGroup": "'+$RESOURCE_GROUP+'"
            }
        ]
    }

]
' | ConvertFrom-Json
