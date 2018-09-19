#!/bin/bash

# Create a resource group VVV
az group create --name RGAZESSENTIALS --location francecentral
# Create a storage for random stores
az storage account create --location westeurope --name azessentialsdemo --resource-group RGAZESSENTIALS --sku Standard_LRS
# Create a virtual network VVV
az network vnet create --resource-group RGAZESSENTIALS --location francecentral --name azdaysvnet --address-prefix 10.100.0.0/14  --subnet-name Subnet1 --subnet-prefix 10.100.1.0/24

# Create a public IP address for the front end web app VVV
az network public-ip create --resource-group RGAZESSENTIALS --name loaded-balanced-front-web-public-ip --dns-name demofrontweb --allocation-method Static

# Create an Azure Load Balancer.
az network lb create --resource-group RGAZESSENTIALS --name load-balancer-front-end-web --public-ip-address loaded-balanced-front-web-public-ip --frontend-ip-name demo-front-end-pool --backend-pool-name demo-front-end-backend-pool

# Creates an LB probe on port 80.
az network lb probe create --resource-group RGAZESSENTIALS --lb-name load-balancer-front-end-web --name health-prob-1-80 --protocol tcp --port 80

# Creates an LB rule for port 80.
az network lb rule create --resource-group RGAZESSENTIALS --lb-name load-balancer-front-end-web --name load-balancer-rule-1-80 --protocol tcp --frontend-port 80 --backend-port 80 --frontend-ip-name demo-front-end-pool --backend-pool-name demo-front-end-backend-pool --probe-name health-prob-1-80


# Creates an LB probe on port 22.
az network lb probe create --resource-group RGAZESSENTIALS --lb-name load-balancer-front-end-web --name health-prob-1-22 --protocol tcp --port 22

# Creates an LB rule for port 22.
az network lb rule create --resource-group RGAZESSENTIALS --lb-name load-balancer-front-end-web --name load-balancer-rule-1-22 --protocol tcp --frontend-port 22 --backend-port 22 --frontend-ip-name demo-front-end-pool --backend-pool-name demo-front-end-backend-pool --probe-name health-prob-1-22



# Creates an LB probe on port 8080.
az network lb probe create --resource-group RGAZESSENTIALS --lb-name load-balancer-front-end-web --name health-prob-1-8080 --protocol tcp --port 8080

# Creates an LB rule for port 8080.
az network lb rule create --resource-group RGAZESSENTIALS --lb-name load-balancer-front-end-web --name load-balancer-rule-1-8080 \
  --protocol tcp --frontend-port 8080 --backend-port 8080 --frontend-ip-name demo-front-end-pool \
  --backend-pool-name demo-front-end-backend-pool --probe-name health-prob-1-8080

# Create a network security group front end
az network nsg create --resource-group RGAZESSENTIALS --name NGS-tier-1

# Create a network security group rule for port 22.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-1 --name NGS-tier-1-rule-22_in \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 22 --access allow --priority 1000

# Create a network security group rule for port 80.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-1 --name NGS-tier-1-rule-80_in \
--protocol tcp --direction inbound  --source-address-prefix '*' --source-port-range '*' \
--destination-address-prefix '*' --destination-port-range 80 --access allow --priority 1001

# Create a network security group rule for port 8080.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-1 --name NGS-tier-1-rule-8080_in \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 8080 --access allow --priority 1002

# Create a network security group rule for port 3306.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-1 --name NGS-tier-1-rule-3306_in \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 3306 --access allow --priority 1003

# Create a network security group rule for port 22_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-1 --name NGS-tier-1-rule-22_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 22 --access allow --priority 2000

# Create a network security group rule for port 80_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-1 --name NGS-tier-1-rule-80_out \
--protocol tcp --direction Outbound  --source-address-prefix '*' --source-port-range '*' \
--destination-address-prefix '*' --destination-port-range 80 --access allow --priority 2001

# Create a network security group rule for port 8080_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-1 --name NGS-tier-1-rule-8080_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 8080 --access allow --priority 2002

# Create a network security group rule for port 3306_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-1 --name NGS-tier-1-rule-3306_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 3306 --access allow --priority 2003


# Update first Subnet with Newly created NSG Rules.
az network vnet subnet update --name Subnet1 --resource-group RGAZESSENTIALS --vnet-name azdaysvnet --network-security-group NGS-tier-1 

# Create three virtual network cards and associate with public IP address and NSG.
for i in `seq 1 2`; do
  az network nic create \
    --resource-group RGAZESSENTIALS --name nic-ub-16-front-web-$i \
    --vnet-name azdaysvnet  --subnet Subnet1 \
    --network-security-group NGS-tier-1 --lb-name load-balancer-front-end-web \
    --lb-address-pools demo-front-end-backend-pool
done

# Create an availability set.
az vm availability-set create --resource-group RGAZESSENTIALS --name Availability-Set-Front --platform-fault-domain-count 2 --platform-update-domain-count 2

# Create three virtual machines,  with correct extensions.
for i in `seq 1 2`; do
  az vm create --resource-group RGAZESSENTIALS --name ub-16-front-web-$i --admin-password M0nP@ssw0rd! --admin-username demo \
   --availability-set Availability-Set-Front \
   --nics nic-ub-16-front-web-$i \
   --image UbuntuLTS \
   --size Standard_B2ms
done

# Now the extensions... with correct extensions.
for i in `seq 1 2`; do
  az vm extension set --resource-group RGAZESSENTIALS --vm-name ub-16-front-web-$i --name customScript --publisher Microsoft.Azure.Extensions \
   --settings '{"fileUris": ["https://raw.githubusercontent.com/fbouteruche/RateAzureEssentials/master/scripts/setup_front.sh"],"commandToExecute": "./setup_front.sh"}'
done

# Now the extensions... with correct extensions.
#for i in `seq 1 2`; do 
#    az vm update --resource-group RGAZESSENTIALS --name ub-16-front-web-$i --set tags.Envirronment=Demo tags.Owner=Teacher
#done

# Create a network security group front middle
az network nsg create --resource-group RGAZESSENTIALS --name NGS-tier-2

# Create a network security group rule for port 22.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-2 --name NGS-tier-2-rule-22_in \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 22 --access allow --priority 1000

# Create a network security group rule for port 80.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-2 --name NGS-tier-2-rule-80_in \
--protocol tcp --direction inbound  --source-address-prefix '*' --source-port-range '*' \
--destination-address-prefix '*' --destination-port-range 80 --access allow --priority 1001

# Create a network security group rule for port 8080.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-2 --name NGS-tier-2-rule-8080_in \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 8080 --access allow --priority 1002

# Create a network security group rule for port 3306.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-2 --name NGS-tier-2-rule-3306_in \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 3306 --access allow --priority 1003 

# Create a network security group rule for port 22_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-2 --name NGS-tier-2-rule-22_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 22 --access allow --priority 2000

# Create a network security group rule for port 80_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-2 --name NGS-tier-2-rule-80_out \
--protocol tcp --direction Outbound  --source-address-prefix '*' --source-port-range '*' \
--destination-address-prefix '*' --destination-port-range 80 --access allow --priority 2001

# Create a network security group rule for port 8080_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-2 --name NGS-tier-2-rule-8080_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 8080 --access allow --priority 2002

# Create a network security group rule for port 3306_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-2 --name NGS-tier-2-rule-3306_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 3306 --access allow --priority 2003

# Create a network security group rule for port 27017_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-2 --name NGS-tier-2-rule-27017_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 27017 --access allow --priority 2004

# Create a network security group rule for port 27018_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-2 --name NGS-tier-2-rule-27018_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 27018 --access allow --priority 2005



#create a subnet for middle app after front end subnet 
az network vnet subnet create --address-prefix 10.100.2.0/24 --name Subnet2 --resource-group RGAZESSENTIALS --vnet-name azdaysvnet --network-security-group NGS-tier-2  

# create loadbalancer between subnet front and subnet backend 
az network lb create --resource-group RGAZESSENTIALS --name load-balancer-front-to-middle --private-ip-address 10.100.2.4 --subnet Subnet2 --vnet-name azdaysvnet --backend-pool-name demo-middle-end-pool

# Creates an LB probe on port 80.
az network lb probe create --resource-group RGAZESSENTIALS --lb-name load-balancer-front-to-middle \
  --name health-prob-1-80 --protocol tcp --port 80

# Creates an LB rule for port 80.
az network lb rule create --resource-group RGAZESSENTIALS --lb-name load-balancer-front-to-middle --name load-balancer-rule-1-80 \
  --protocol tcp --frontend-port 80 --backend-port 80  \
  --backend-pool-name demo-middle-end-pool --probe-name health-prob-1-80

# Creates an LB probe on port 8080.
az network lb probe create --resource-group RGAZESSENTIALS --lb-name load-balancer-front-to-middle \
  --name health-prob-1-8080 --protocol tcp --port 8080

# Creates an LB rule for port 8080.
az network lb rule create --resource-group RGAZESSENTIALS --lb-name load-balancer-front-to-middle --name load-balancer-rule-1-8080 \
  --protocol tcp --frontend-port 8080 --backend-port 8080  \
  --backend-pool-name demo-middle-end-pool --probe-name health-prob-1-8080

# Creates an LB probe on port 22.
az network lb probe create --resource-group RGAZESSENTIALS --lb-name load-balancer-front-to-middle \
  --name health-prob-1-22 --protocol tcp --port 22

# Creates an LB rule for port 22.
az network lb rule create --resource-group RGAZESSENTIALS --lb-name load-balancer-front-to-middle --name load-balancer-rule-1-22 \
  --protocol tcp --frontend-port 22 --backend-port 22  \
  --backend-pool-name demo-middle-end-pool --probe-name health-prob-1-22



# Create three virtual network cards and associate with public IP address and NSG.
for i in `seq 1 2`; do
  az network nic create \
    --resource-group RGAZESSENTIALS --name nic-ub-16-back-end-$i \
    --vnet-name azdaysvnet  --subnet Subnet2 \
    --network-security-group NGS-tier-2 --lb-name load-balancer-front-to-middle \
    --lb-address-pools demo-middle-end-pool
done

# Create an availability set.
az vm availability-set create --resource-group RGAZESSENTIALS --name Availability-Set-back-end-2 --platform-fault-domain-count 2 --platform-update-domain-count 2

# Create three virtual machines,  with correct extensions.
for i in `seq 1 2`; do
  az vm create --resource-group RGAZESSENTIALS --name ub-16-back-end-$i --admin-password M0nP@ssw0rd! --admin-username demo \
   --availability-set Availability-Set-back-end-2 \
   --nics nic-ub-16-back-end-$i\
   --image UbuntuLTS \
   --size Standard_DS2_v2
done

# Now the extensions... with correct extensions.
for i in `seq 1 2`; do
  az vm extension set --resource-group RGAZESSENTIALS --vm-name ub-16-back-end-$i --name customScript --publisher Microsoft.Azure.Extensions \
   --settings '{"fileUris": ["https://raw.githubusercontent.com/fbouteruche/RateAzureEssentials/master/scripts/setup_middle.sh"],"commandToExecute": "./setup_middle.sh"}'
done

# Now the extensions... with correct extensions.
#for i in `seq 1 2`; do 
#    az vm update --resource-group RGAZESSENTIALS --name ub-16-back-end-$i --set tags.Envirronment=Demo tags.Owner=Teacher
#done




