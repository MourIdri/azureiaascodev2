

# Create a network security group Storage
az network nsg create --resource-group RGAZESSENTIALS --name NGS-tier-3

# Create a network security group rule for port 22.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-3 --name NGS-tier-3-rule-22_in \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 22 --access allow --priority 1000

# Create a network security group rule for port 80.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-3 --name NGS-tier-3-rule-80_in \
--protocol tcp --direction inbound  --source-address-prefix '*' --source-port-range '*' \
--destination-address-prefix '*' --destination-port-range 80 --access allow --priority 1001

# Create a network security group rule for port 8080.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-3 --name NGS-tier-3-rule-8080_in \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 8080 --access allow --priority 1002

# Create a network security group rule for port 3306.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-3 --name NGS-tier-3-rule-3306_in \
  --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 3306 --access allow --priority 1003 

# Create a network security group rule for port 22_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-3 --name NGS-tier-3-rule-22_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 22 --access allow --priority 2000

# Create a network security group rule for port 80_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-3 --name NGS-tier-3-rule-80_out \
--protocol tcp --direction Outbound  --source-address-prefix '*' --source-port-range '*' \
--destination-address-prefix '*' --destination-port-range 80 --access allow --priority 2001

# Create a network security group rule for port 8080_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-3 --name NGS-tier-3-rule-8080_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 8080 --access allow --priority 2002

# Create a network security group rule for port 3306_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-3 --name NGS-tier-3-rule-3306_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 3306 --access allow --priority 2003

# Create a network security group rule for port 27017_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-3 --name NGS-tier-3-rule-27017_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 27017 --access allow --priority 2004

# Create a network security group rule for port 27018_out.
az network nsg rule create --resource-group RGAZESSENTIALS --nsg-name NGS-tier-3 --name NGS-tier-3-rule-27018_out \
  --protocol tcp --direction Outbound --source-address-prefix '*' --source-port-range '*'  \
  --destination-address-prefix '*' --destination-port-range 27018 --access allow --priority 2005



#create a subnet for middle app after front end subnet 
az network vnet subnet create --address-prefix 10.100.3.0/24 --name Subnet3 --resource-group RGAZESSENTIALS --vnet-name azdaysvnet --network-security-group NGS-tier-3  

# create loadbalancer between subnet front and subnet backend 
az network lb create --resource-group RGAZESSENTIALS --name load-balancer-middle-to-storage --private-ip-address 10.100.3.4 --subnet Subnet3 --vnet-name azdaysvnet --backend-pool-name demo-storage-end-pool

# Creates an LB probe on port 80.
az network lb probe create --resource-group RGAZESSENTIALS --lb-name load-balancer-middle-to-storage \
  --name health-prob-1-80 --protocol tcp --port 80

# Creates an LB rule for port 80.
az network lb rule create --resource-group RGAZESSENTIALS --lb-name load-balancer-middle-to-storage --name load-balancer-rule-1-80 \
  --protocol tcp --frontend-port 80 --backend-port 80  \
  --backend-pool-name demo-storage-end-pool --probe-name health-prob-1-80

# Creates an LB probe on port 8080.
az network lb probe create --resource-group RGAZESSENTIALS --lb-name load-balancer-middle-to-storage \
  --name health-prob-1-8080 --protocol tcp --port 8080

# Creates an LB rule for port 8080.
az network lb rule create --resource-group RGAZESSENTIALS --lb-name load-balancer-middle-to-storage --name load-balancer-rule-1-8080 \
  --protocol tcp --frontend-port 8080 --backend-port 8080  \
  --backend-pool-name demo-storage-end-pool --probe-name health-prob-1-8080

# Creates an LB probe on port 22.
az network lb probe create --resource-group RGAZESSENTIALS --lb-name load-balancer-middle-to-storage \
  --name health-prob-1-22 --protocol tcp --port 22

# Creates an LB rule for port 22.
az network lb rule create --resource-group RGAZESSENTIALS --lb-name load-balancer-middle-to-storage --name load-balancer-rule-1-22 \
  --protocol tcp --frontend-port 22 --backend-port 22  \
  --backend-pool-name demo-storage-end-pool --probe-name health-prob-1-22

# Creates an LB probe on port 27017.
az network lb probe create --resource-group RGAZESSENTIALS --lb-name load-balancer-middle-to-storage \
  --name health-prob-1-27017 --protocol tcp --port 27017

# Creates an LB rule for port 27017.
az network lb rule create --resource-group RGAZESSENTIALS --lb-name load-balancer-middle-to-storage --name load-balancer-rule-1-27017 \
  --protocol tcp --frontend-port 27017 --backend-port 27017  \
  --backend-pool-name demo-storage-end-pool --probe-name health-prob-1-27017

# Creates an LB probe on port 27018.
az network lb probe create --resource-group RGAZESSENTIALS --lb-name load-balancer-middle-to-storage \
  --name health-prob-1-27018 --protocol tcp --port 27018

# Creates an LB rule for port 27018.
az network lb rule create --resource-group RGAZESSENTIALS --lb-name load-balancer-middle-to-storage --name load-balancer-rule-1-27018 \
  --protocol tcp --frontend-port 27018 --backend-port 27018  \
  --backend-pool-name demo-storage-end-pool --probe-name health-prob-1-27018



# Create three virtual network cards and associate with public IP address and NSG.
for i in `seq 1 2`; do
  az network nic create \
    --resource-group RGAZESSENTIALS --name nic-ub-16-demo-db-$i \
    --vnet-name azdaysvnet  --subnet Subnet3 \
    --network-security-group NGS-tier-3 --lb-name load-balancer-middle-to-storage \
    --lb-address-pools demo-storage-end-pool
done

# Create an availability set.
az vm availability-set create --resource-group RGAZESSENTIALS --name Availability-Set-storage-DB --platform-fault-domain-count 2 --platform-update-domain-count 2

# Create three virtual machines,  with correct extensions.
for i in `seq 1 2`; do
  az vm create --resource-group RGAZESSENTIALS --name ub-16-demo-db-$i --admin-password M0nP@ssw0rd! --admin-username demo \
   --availability-set Availability-Set-storage-DB \
   --nics nic-ub-16-demo-db-$i\
   --image UbuntuLTS \
   --size Standard_DS2_v2
done

# Now the extensions... with correct extensions.
for i in `seq 1 2`; do
  az vm extension set --resource-group RGAZESSENTIALS --vm-name ub-16-demo-db-$i --name customScript --publisher Microsoft.Azure.Extensions \
   --settings '{"fileUris": ["https://raw.githubusercontent.com/fbouteruche/RateAzureEssentials/master/scripts/setup_mongodb.sh"],"commandToExecute": "./setup_mongodb.sh"}'
done

# Now the extensions... with correct extensions.
#for i in `seq 1 2`; do 
#    az vm update --resource-group RGAZESSENTIALS --name ub-16-demo-db-$i --set tags.Envirronment=Demo tags.Owner=Teacher
#done





