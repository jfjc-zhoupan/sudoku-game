# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "4b4511ba-165a-4df2-be28-75937cfe1031" # use a specific subscription
  tenant_id       = "964f9745-bd07-4d1d-9a24-40f9bc141cc4" # if across tenant necessary
}

# Create a resource group
resource "azurerm_resource_group" "rg-webapp" {
  name     = "rg-webapp"
  location = var.location
}

module "network-webapp" {
    source = "./modules/network"
    location = var.location
    rg_name = azurerm_resource_group.rg-webapp.name
    vnet_name = "vnet-webapp"
    address_space = ["10.1.0.0/16"]
    subnet1_cidr = ["10.1.0.0/24"]
    subnet2_cidr = ["10.1.1.0/24"]
    env_tag = "dev"
    nic_name = "nic-webapp"
    publicip_name = "pip-webapp"
}

module "vm-webapp" {
    source = "./modules/compute"
    location = var.location
    rg_name = azurerm_resource_group.rg-webapp.name
    vm_name = "vm-webapp"
    vm_size = "Standard_D4s_v4"
    admin_username = "zhou"
    nic_id = module.network-webapp.nic_id
    public_key = file(var.public_key_path)
    env_tag = "dev"
    
    user_data_script = var.user_data_script
    docker_user = var.docker_user
    docker_pass = var.docker_pass
}