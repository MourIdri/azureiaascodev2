# AZURE ESSENTIALS Essentials

# start of demo 1 

Creation VM via Portal and cli

   0.1 : Env & Network _ Create RG 
       
     az group create --name DemoRG --location francecentral

   0.2 : Env & Network _ Create Vnet and subnets
     
     az network vnet create --resource-group DemoRG --location francecentral --name DemoVnet --address-prefix 192.168.240.0/24  --subnet-name Subnet1 --subnet-prefix 192.168.240.0/28
     az network vnet subnet create --address-prefix 192.168.245.16/28 --name Subnet2 --resource-group DemoRG --vnet-name DemoVnet
     az network vnet subnet create --address-prefix 192.168.245.32/28 --name Subnet3 --resource-group DemoRG --vnet-name DemoVnet
     az network vnet subnet create --address-prefix 192.168.245.48/28 --name Subnet4 --resource-group DemoRG --vnet-name DemoVnet

   0.3 : Env & Network _ Create security groups and update subnets

    # Create NSG1
     az network nsg create --resource-group DemoRG --name NSG1
    # Create a network security group rule for port 80.
     az network nsg rule create --resource-group DemoRG --nsg-name NSG1 --name NGS1-80_in \
      --protocol tcp --direction inbound  --source-address-prefix '*' --source-port-range '*' \
      --destination-address-prefix '*' --destination-port-range 80 --access allow --priority 1001
    # Update Subnet1 with NSG1
     az network vnet subnet update --name Subnet1 --resource-group DemoRG --vnet-name DemoVnet --network-security-group NSG1

    # Create NSG2
     az network nsg create --resource-group DemoRG --name NSG2
    #  Create a network security group rule for port 80. 
     az network nsg rule create --resource-group DemoRG --nsg-name NSG2 --name NGS2-80_in \
     --protocol tcp --direction inbound  --source-address-prefix '*' --source-port-range '*' \
     --destination-address-prefix '*' --destination-port-range 80 --access allow --priority 1002
    # Update Subnet2 with NSG2
     az network vnet subnet update --name Subnet2 --resource-group DemoRG --vnet-name DemoVnet --network-security-group NSG2

    # Create NSG3
     az network nsg create --resource-group DemoRG --name NSG3
    #Create a network security group rule for port 27018 MONGODB.
     az network nsg rule create --resource-group DemoRG --nsg-name NSG3 --name NSG3-27018_in \
    --protocol tcp --direction inbound  --source-address-prefix '*' --source-port-range '*' \
    --destination-address-prefix '*' --destination-port-range 27018 --access allow --priority 1003
    # Update Subnet3 with NSG3
     az network vnet subnet update --name Subnet3 --resource-group DemoRG --vnet-name DemoVnet --network-security-group NSG3

    # Create NSG4
     az network nsg create --resource-group DemoRG --name NSG4
    #Create a network security group rule for port 3389 RDP.
     az network nsg rule create --resource-group DemoRG --nsg-name NSG4 --name NSG4-3389_in \
    --protocol tcp --direction inbound  --source-address-prefix '*' --source-port-range '*' \
    --destination-address-prefix '*' --destination-port-range 3389 --access allow --priority 1004
    # Update Subnet4 with NSG4
     az network vnet subnet update --name Subnet4 --resource-group DemoRG --vnet-name DemoVnet --network-security-group NSG4

   0.3 : Env & Network _ Public IP for frontend access
   
    #Create a public IP address for the front end web app VVV
     az network public-ip create --resource-group DemoRG --name front-end-pu-ip --dns-name azessentialsfront --allocation-method Static

   1.1 : Compute & Storage _ Create Storage Account for general purposes
   
    #Create a storage account 
     az storage account create --location westeurope --name changemynametobeunique --resource-group DemoRG --sku Standard_LRS

   1.2 : Compute & Storage _ Create frontend compute 
     
     # Create NIC for the VM front :
      az network nic create --resource-group DemoRG --name NIC-VM1 --vnet-name DemoVnet  --subnet Subnet1 
    
     # Create the VM front :
      az vm create --resource-group DemoRG --name VM1 --admin-password M0nP@ssw0rd! --admin-username demo --nics NIC-VM1  --image UbuntuLTS --size Standard_B2ms --os-disk-size-gb 32
 
      # Create NIC for the VM middle :
      az network nic create --resource-group DemoRG --name NIC-VM2 --vnet-name DemoVnet  --subnet Subnet2
      
     # Create the VM middle :
      az vm create --resource-group DemoRG --name VM2 --admin-password M0nP@ssw0rd! --admin-username demo --nics NIC-VM2 --image UbuntuLTS --size Standard_DS2_v2 --os-disk-size-gb 32
 
      # Create NIC for the VM storage :
      az network nic create --resource-group DemoRG --name NIC-VM3 --vnet-name DemoVnet  --subnet Subnet3 
      
     # Create the VM Storage :
      az vm create --resource-group DemoRG --name VM3 --admin-password M0nP@ssw0rd! --admin-username demo --nics NIC-VM3 --image UbuntuLTS --size Standard_DS2_v2 --os-disk-size-gb 32 
      
     # Attach a New Disk to the VM storage 
      az vm disk attach -g DemoRG --vm-name vm-storage --disk vm-storage-disk-1 --new --size-gb 50
  
      # Create NIC for the VM admin :
      az network nic create --resource-group DemoRG --name NIC-VM4 --vnet-name DemoVnet  --subnet Subnet4
      
      # Create the VM admin :
      az vm create --resource-group DemoRG --name VM4 --admin-password M0nP@ssw0rd! --admin-username demo --nics NIC-VM4 --image win2016datacenter --size Standard_B2ms --os-disk-size-gb 32    

# end of demo 1

# start of demo 2

Preparation for Demo 2 : Before going further open the embeded cli in azure portal. Make sure you can use your default subscription and download the script from here : 

      wget https://raw.githubusercontent.com/MourIdri/azureiaascodev1/master/1_deploy_front_and_back_end_app.sh
      wget https://raw.githubusercontent.com/MourIdri/azureiaascodev1/master/2_deploy_DB_server.sh
      
Copy- past the content of the script into the CLI portal and let the sequence to finish for both script  since bash is not very effecive... Or use a Linux client with Azcli installed on it, then you can do : 

      chmod 777 1_deploy_front_and_back_end_app.sh
      chmod 777 2_deploy_DB_server.sh
      ./1_deploy_front_and_back_end_app.sh
      ./2_deploy_DB_server.sh

then wait for the 2 to be finished ( use 2 browser or any linux client with AZCLI on it to do it faster ). 
This will create 3 tiers applications and on each tier, there is a load balanced Availibility set with 2 VMs on it. 

Demo 2 : 

   2.1 : Resize the VMs and monitor the traffic if the service is still available. 
   
    # Resize the VM

     az vm resize --resource-group --resource-group DemoRG --name ub-16-front-web-1 --size Standard_DS3_v2

   2.2 : Go to your resource group and check in "Automation script" you will see the deployed resources as a template with some languages

   2.3 : Deploy resource group with a VM from a Json. Open the Azure Cli and proceed : 
   
    #Download the template and the paramters uisng this 
     wget https://raw.githubusercontent.com/MourIdri/azureiaascodev1/master/azuredeploy.json
     wget https://raw.githubusercontent.com/MourIdri/azureiaascodev1/master/azuredeploy.parameters.json
    #Create a ressource group since the Json will not create the resource itself : 
     az group create --name DemoRGJSON --location "westeurope"
    #Start the deploiment using this command : 
     az group deployment create -g DemoRGJSON --template-uri https://raw.githubusercontent.com/MourIdri/azureiaascodev1/master/azuredeploy.json --parameters @azuredeploy.parameters.json
    
# end of demo 2
