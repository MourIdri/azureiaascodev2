# Az Essentials

START OF DEMO 1 

Creation VM via Portal and cli

   0.1 : Env & Network _ Create RG 
       
    >_ az group create --name DemoRG --location francecentral

   0.2 : Env & Network _ Create Vnet and subnets
     
    >_ az network vnet create --resource-group DemoRG --location francecentral --name DemoVnet --address-prefix 192.168.240.0/24  --subnet-name Subnet1 --subnet-prefix 192.168.240.0/28
    >_ az network vnet subnet create --address-prefix 192.168.245.16/28 --name Subnet2 --resource-group DemoRG --vnet-name DemoVnet
    >_ az network vnet subnet create --address-prefix 192.168.245.32/28 --name Subnet3 --resource-group DemoRG --vnet-name DemoVnet
    >_ az network vnet subnet create --address-prefix 192.168.245.48/28 --name Subnet4 --resource-group DemoRG --vnet-name DemoVnet

   0.3 : Env & Network _ Create security groups and update subnets

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

   0.3 : Env & Network _ Public IP for frontend access
   
    #Create a public IP address for the front end web app VVV
    >_ az network public-ip create --resource-group DemoRG --name front-end-pu-ip --dns-name azessentialsfront --allocation-method Static

   1.1 : Compute & Storage _ Create Storage Account for general purposes
   
    #Create a storage account 
    >_ az storage account create --location westeurope --name changemynametobeunique --resource-group DemoRG --sku Standard_LRS

   1.2 : Compute & Storage _ Create frontend compute 
     
     # Create NIC for the VM front :
     >_ az network nic create \
    --resource-group DemoRG --name nic-vm-front \
    --vnet-name DemoVnet  --subnet Subnet1 \
    --network-security-group NGS1 \
     # Create the VM front :
     >_ az vm create --resource-group DemoRG --name vm-front --admin-password M0nP@ssw0rd! --admin-username demo \
     --nics nic-vm-front \ 
     --image UbuntuLTS \
     --size Standard_B2ms --os-disk-size-gb 32
 
      # Create NIC for the VM middle :
     >_ az network nic create \
    --resource-group DemoRG --name nic-vm-middle \
    --vnet-name DemoVnet  --subnet Subnet2 \
    --network-security-group NGS2 \
     # Create the VM front :
     >_ az vm create --resource-group DemoRG --name vm-middle --admin-password M0nP@ssw0rd! --admin-username demo \
     --nics nic-vm-middle \ 
     --image UbuntuLTS \
     --size Standard_DS2_v2 --os-disk-size-gb 32
 
      # Create NIC for the VM storage :
     >_ az network nic create \
    --resource-group DemoRG --name nic-vm-storage \
    --vnet-name DemoVnet  --subnet Subnet3 \
    --network-security-group NGS3 \
     # Create the VM front :
     >_ az vm create --resource-group DemoRG --name vm-storage --admin-password M0nP@ssw0rd! --admin-username demo \
     --nics nic-vm-storage \ 
     --image UbuntuLTS \
     --size Standard_DS2_v2 --os-disk-size-gb 32
  
      # Create NIC for the VM admin :
     >_ az network nic create \
    --resource-group DemoRG --name nic-vm-admin \
    --vnet-name DemoVnet  --subnet Subnet4 \
    --network-security-group NGS4 \
     # Create the VM front :
     >_ az vm create --resource-group DemoRG --name vm-admin --admin-password M0nP@ssw0rd! --admin-username demo \
     --nics nic-vm-storage \ 
     --image win2016datacenter \
     --size Standard_B2ms --os-disk-size-gb 32    

END OF DEMO 1 

START OF DEMO 2
Preparation for Demo 2 : Before going further open the embeded cli in azure portal. Make sure you can use your default subscription and download the script from here : 

      >_ wget https://raw.githubusercontent.com/MourIdri/azureiaascodev1/master/1_deploy_front_and_back_end_app.sh
      >_ wget https://raw.githubusercontent.com/MourIdri/azureiaascodev1/master/2_deploy_DB_server.sh
      
Copy- past the content of the script into the CLI portal and let the sequence to finish for both script  since bash is not very effecive... Or use a Linux client with Azcli installed on it, then you can do : 

      >_ chmod 777 1_deploy_front_and_back_end_app.sh
      >_ chmod 777 2_deploy_DB_server.sh
      >_ ./1_deploy_front_and_back_end_app.sh
      >_ ./2_deploy_DB_server.sh

then wait for the 2 to be finished ( use 2 browser or any linux client with AZCLI on it to do it faster ). 
This will create 3 tiers applications and on each tier, there is a load balanced Availibility set with 2 VMs on it. 

Demo 2 : 

   2.1 : Resize the VMs and monitor the traffic if the service is still available. 
   
    #Create a storage account 
    az vm resize --resource-group myResourceGroup --name myVM --size Standard_DS3_v2
    >_ az vm resize --resource-group --resource-group DemoRG --name ub-16-front-web-1 --size Standard_DS3_v2

Démo 2 : 
Resize VM and Deploy using Json template 
  
