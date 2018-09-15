#!/bin/bash

# Create a resource group VVV
az group create --name RGMOURAD_0 --location eastus
# Create a virtual network VVV
az network vnet create --resource-group RGMOURAD_0 --location eastus --name vnet-root_2 --address-prefix 10.100.0.0/14  --subnet-name subnet-primary --subnet-prefix 10.100.1.0/24

# Create a public IP address for the front end web app VVV
az network public-ip create --resource-group RGMOURAD_0 --name loaded-balanced-front-web-public-ip --dns-name demofrontweb --allocation-method Static

# Create an Azure Load Balancer.
az network lb create --resource-group RGMOURAD_0 --name load-balancer-front-end-web --public-ip-address loaded-balanced-front-web-public-ip --frontend-ip-name demo-front-end-pool --backend-pool-name demo-front-end-backend-pool

# Creates an LB probe on port 80.
az network lb probe create --resource-group RGMOURAD_0 --lb-name load-balancer-front-end-web --name health-prob-1-80 --protocol tcp --port 80

# Creates an LB rule for port 80.
az network lb rule create --resource-group RGMOURAD_0 --lb-name load-balancer-front-end-web --name load-balancer-rule-1-80 --protocol tcp --frontend-port 80 --backend-port 80 --frontend-ip-name demo-front-end-pool --backend-pool-name demo-front-end-backend-pool --probe-name health-prob-1-80

# Creates an LB probe on port 8080.
az network lb probe create --resource-group RGMOURAD_0 --lb-name load-balancer-front-end-web --name health-prob-1-8080 --protocol tcp --port 8080

# Creates an LB rule for port 8080.
az network lb rule create --resource-group RGMOURAD_0 --lb-name load-balancer-front-end-web --name load-balancer-rule-1-8080 \
  --protocol tcp --frontend-port 8080 --backend-port 8080 --frontend-ip-name demo-front-end-pool \
  --backend-pool-name demo-front-end-backend-pool --probe-name health-prob-1-8080

# Create a network security group front end
az network nsg create --resource-group RGMOURAD_0 --name NGS-generic-linux-N-tier-1

# Create a network security group rule for port 22.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-1 --name NGS-generic-linux-N-tier-1-rule-22_in \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 22 --access allow --priority 1000

# Create a network security group rule for port 80.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-1 --name NGS-generic-linux-N-tier-1-rule-80_in \
--protocol tcp --direction inbound  --source-address-prefix '*' --source-port-range '*' \
--destination-address-prefix '*' --destination-port-range 80 --access allow --priority 1001

# Create a network security group rule for port 8080.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-1 --name NGS-generic-linux-N-tier-1-rule-8080_in \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 8080 --access allow --priority 1002

# Create a network security group rule for port 3306.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-1 --name NGS-generic-linux-N-tier-1-rule-3306_in \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 3306 --access allow --priority 1003

# Create a network security group rule for port 22_out.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-1 --name NGS-generic-linux-N-tier-1-rule-22_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 22 --access allow --priority 2000

# Create a network security group rule for port 80_out.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-1 --name NGS-generic-linux-N-tier-1-rule-80_out \
--protocol tcp --direction Outbound  --source-address-prefix '*' --source-port-range '*' \
--destination-address-prefix '*' --destination-port-range 80 --access allow --priority 2001

# Create a network security group rule for port 8080_out.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-1 --name NGS-generic-linux-N-tier-1-rule-8080_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 8080 --access allow --priority 2002

# Create a network security group rule for port 3306_out.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-1 --name NGS-generic-linux-N-tier-1-rule-3306_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 3306 --access allow --priority 2003

# Update first Subnet with Newly created NSG Rules.
az network vnet subnet update --name subnet-primary --resource-group RGMOURAD_0 --vnet-name vnet-root_2 --network-security-group NGS-generic-linux-N-tier-1 

# Create three virtual network cards and associate with public IP address and NSG.
for i in `seq 1 3`; do
  az network nic create \
    --resource-group RGMOURAD_0 --name nic-ub-16-front-web-$i \
    --vnet-name vnet-root_2  --subnet subnet-primary \
    --network-security-group NGS-generic-linux-N-tier-1 --lb-name load-balancer-front-end-web \
    --lb-address-pools demo-front-end-backend-pool
done

# Create an availability set.
az vm availability-set create --resource-group RGMOURAD_0 --name Availability-Set-Front --platform-fault-domain-count 3 --platform-update-domain-count 3

# Create three virtual machines,  with correct extensions.
for i in `seq 1 3`; do
  az vm create --resource-group RGMOURAD_0 --name ub-16-front-web-$i --admin-password M0nP@ssw0rd! --admin-username demo \
   --availability-set Availability-Set-Front \
   --nics nic-ub-16-front-web-$i \
   --image UbuntuLTS \
   --size Standard_DS2_v2
done

# Now the extensions... with correct extensions.
for i in `seq 1 3`; do
  az vm extension set --resource-group RGMOURAD_0 --vm-name ub-16-front-web-$i --name customScript --publisher Microsoft.Azure.Extensions \
   --settings '{"fileUris": ["https://rgcloudmouradgeneralpurp.blob.core.windows.net/exchangecontainermourad/sh_bootstrap_pu.sh"],"commandToExecute": "./sh_bootstrap_pu.sh"}'
done

# Create a network security group front middle
az network nsg create --resource-group RGMOURAD_0 --name NGS-generic-linux-N-tier-2

# Create a network security group rule for port 22.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-2 --name NGS-generic-linux-N-tier-2-rule-22_in \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 22 --access allow --priority 1000

# Create a network security group rule for port 80.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-2 --name NGS-generic-linux-N-tier-2-rule-80_in \
--protocol tcp --direction inbound  --source-address-prefix '*' --source-port-range '*' \
--destination-address-prefix '*' --destination-port-range 80 --access allow --priority 1001

# Create a network security group rule for port 8080.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-2 --name NGS-generic-linux-N-tier-2-rule-8080_in \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 8080 --access allow --priority 1002

# Create a network security group rule for port 3306.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-2 --name NGS-generic-linux-N-tier-2-rule-3306_in \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 3306 --access allow --priority 1003 

# Create a network security group rule for port 22_out.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-2 --name NGS-generic-linux-N-tier-2-rule-22_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 22 --access allow --priority 2000

# Create a network security group rule for port 80_out.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-2 --name NGS-generic-linux-N-tier-2-rule-80_out \
--protocol tcp --direction Outbound  --source-address-prefix '*' --source-port-range '*' \
--destination-address-prefix '*' --destination-port-range 80 --access allow --priority 2001

# Create a network security group rule for port 8080_out.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-2 --name NGS-generic-linux-N-tier-2-rule-8080_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 8080 --access allow --priority 2002

# Create a network security group rule for port 3306_out.
az network nsg rule create --resource-group RGMOURAD_0 --nsg-name NGS-generic-linux-N-tier-2 --name NGS-generic-linux-N-tier-2-rule-3306_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 3306 --access allow --priority 2003

#create a subnet for middle app after front end subnet 
az network vnet subnet create --address-prefix 10.100.2.0/24 --name subnet-middle --resource-group RGMOURAD_0 --vnet-name vnet-root_2 --network-security-group NGS-generic-linux-N-tier-2  

# create loadbalancer between subnet front and subnet backend 
az network lb create --resource-group RGMOURAD_0 --name load-balancer-front-to-middle --private-ip-address 10.100.2.4 --subnet subnet-middle --vnet-name vnet-root_2 --backend-pool-name demo-middle-end-pool

# Creates an LB probe on port 80.
az network lb probe create --resource-group RGMOURAD_0 --lb-name load-balancer-front-to-middle \
  --name health-prob-1-80 --protocol tcp --port 80

# Creates an LB rule for port 80.
az network lb rule create --resource-group RGMOURAD_0 --lb-name load-balancer-front-to-middle --name load-balancer-rule-1-80 \
  --protocol tcp --frontend-port 80 --backend-port 80  \
  --backend-pool-name demo-middle-end-pool --probe-name health-prob-1-80

# Creates an LB probe on port 8080.
az network lb probe create --resource-group RGMOURAD_0 --lb-name load-balancer-front-to-middle \
  --name health-prob-1-8080 --protocol tcp --port 8080

# Creates an LB rule for port 8080.
az network lb rule create --resource-group RGMOURAD_0 --lb-name load-balancer-front-to-middle --name load-balancer-rule-1-8080 \
  --protocol tcp --frontend-port 8080 --backend-port 8080  \
  --backend-pool-name demo-middle-end-pool --probe-name health-prob-1-8080

# Create three virtual network cards and associate with public IP address and NSG.
for i in `seq 1 3`; do
  az network nic create \
    --resource-group RGMOURAD_0 --name nic-ub-16-back-end-$i \
    --vnet-name vnet-root_2  --subnet subnet-middle \
    --network-security-group NGS-generic-linux-N-tier-2 --lb-name load-balancer-front-to-middle \
    --lb-address-pools demo-middle-end-pool
done

# Create an availability set.
az vm availability-set create --resource-group RGMOURAD_0 --name Availability-Set-back-end-2 --platform-fault-domain-count 3 --platform-update-domain-count 3

# Create three virtual machines,  with correct extensions.
for i in `seq 1 3`; do
  az vm create --resource-group RGMOURAD_0 --name ub-16-back-end-$i --admin-password M0nP@ssw0rd! --admin-username demo \
   --availability-set Availability-Set-back-end-2 \
   --nics nic-ub-16-back-end-$i\
   --image UbuntuLTS \
   --size Standard_DS2_v2
done

# Now the extensions... with correct extensions.
for i in `seq 1 3`; do
  az vm extension set --resource-group RGMOURAD_0 --vm-name ub-16-back-end-$i --name customScript --publisher Microsoft.Azure.Extensions \
   --settings '{"fileUris": ["https://rgcloudmouradgeneralpurp.blob.core.windows.net/exchangecontainermourad/sh_bootstrap_app.sh"],"commandToExecute": "./sh_bootstrap_app.sh"}'
done
