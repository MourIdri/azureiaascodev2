# Az Essentials

Demo 1 : 
Creation VM via Portal and cli

   0.1 : Create RG 
       
    >_ az group create --name DemoRG --location francecentral

   0.2 : Create Vnet and subnets
     
    >_ az network vnet create --resource-group DemoRG --location francecentral --name DemoVnet --address-prefix 192.168.240.0/24  --subnet-name Subnet1 --subnet-prefix 192.168.240.0/28
    >_ az network vnet subnet create --address-prefix 192.168.245.16/28 --name Subnet2 --resource-group DemoRG --vnet-name DemoVnet
    >_ az network vnet subnet create --address-prefix 192.168.245.32/28 --name Subnet3 --resource-group DemoRG --vnet-name DemoVnet
    >_ az network vnet subnet create --address-prefix 192.168.245.48/28 --name Subnet4 --resource-group DemoRG --vnet-name DemoVnet

   0.3 : Create security groups and update subnets

    # Create NSG1
    >_ az network nsg create --resource-group DemoRG --name NSG1
    # Create a network security group rule for port 80.
    >_ az network nsg rule create --resource-group DemoRG --nsg-name NSG1 --name NGS1-80_in \
      --protocol tcp --direction inbound  --source-address-prefix '*' --source-port-range '*' \
      --destination-address-prefix '*' --destination-port-range 80 --access allow --priority 1001
    # Update Subnet1 with NSG1
    >_ az network vnet subnet update --name Subnet1 --resource-group DemoRG --vnet-name DemoVnet --network-security-group NSG1

    # Create NSG2
    >_ az network nsg create --resource-group DemoRG --name NSG2
    #  Create a network security group rule for port 80. 
    >_ az network nsg rule create --resource-group DemoRG --nsg-name NSG2 --name NGS2-80_in \
     --protocol tcp --direction inbound  --source-address-prefix '*' --source-port-range '*' \
     --destination-address-prefix '*' --destination-port-range 80 --access allow --priority 1002
    # Update Subnet2 with NSG2
    >_ az network vnet subnet update --name Subnet2 --resource-group DemoRG --vnet-name DemoVnet --network-security-group NSG2

    # Create NSG3
    >_ az network nsg create --resource-group DemoRG --name NSG3
    #Create a network security group rule for port 27018 MONGODB.
    >_ az network nsg rule create --resource-group DemoRG --nsg-name NSG3 --name NSG3-27018_in \
    --protocol tcp --direction inbound  --source-address-prefix '*' --source-port-range '*' \
    --destination-address-prefix '*' --destination-port-range 27018 --access allow --priority 1003
    # Update Subnet3 with NSG3
    >_ az network vnet subnet update --name Subnet3 --resource-group DemoRG --vnet-name DemoVnet --network-security-group NSG3

    # Create NSG4
    >_ az network nsg create --resource-group DemoRG --name NSG4
    #Create a network security group rule for port 3389 RDP.
    >_ az network nsg rule create --resource-group DemoRG --nsg-name NSG4 --name NSG4-3389_in \
    --protocol tcp --direction inbound  --source-address-prefix '*' --source-port-range '*' \
    --destination-address-prefix '*' --destination-port-range 3389 --access allow --priority 1004
    # Update Subnet4 with NSG4
    >_ az network vnet subnet update --name Subnet4 --resource-group DemoRG --vnet-name DemoVnet --network-security-group NSG4

Create VMs
    >_ 1.1 : VM_1 (front end) : using portal 
    1.2 : VM_2 (middleware): using cli
    1.3 : VM_3 (storage): using portal , market place mongodb server 
    1.4 : VM_4 (Admin): using cli 
Démo 2 : 
Resize VM and Deploy using Json template 
  
