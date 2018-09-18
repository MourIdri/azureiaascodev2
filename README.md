# Az Essentials

Demo 1 : 
Creation VM via Portal and cli

   1.1 : Create RG 
       
       >_az group create --name DemoRG --location francecentral

   1.2 : Create Vnet and subnets
   
      >_az network vnet create --resource-group DemoRG --location francecentral --name DemoVnet --address-prefix 192.168.240.0/24  --subnet-name Subnet1 --subnet-prefix 192.168.240.0/28
    >_az network vnet subnet create --address-prefix 192.168.245.16/28 --name Subnet2 --resource-group DemoRG --vnet-name DemoVnet
    >_az network vnet subnet create --address-prefix 192.168.245.32/28 --name Subnet3 --resource-group DemoRG --vnet-name DemoVnet
    >_az network vnet subnet create --address-prefix 192.168.245.48/28 --name Subnet4 --resource-group DemoRG --vnet-name DemoVnet

   1.3 : Create security groups 

    >_ 1.1 : VM_1 (front end) : using portal 
    1.2 : VM_2 (middleware): using cli
    1.3 : VM_3 (storage): using portal , market place mongodb server 
    1.4 : VM_4 (Admin): using cli 
Démo 2 : 
Resize VM and Deploy using Json template 
  
