output "nic_id" {
    value = azurerm_network_interface.nic.id
}

output "nic_name" {
    value = azurerm_network_interface.nic.name
}

output "public_ip_address" {
  description = "The public IP address of the resource"
  value       = azurerm_public_ip.pip.ip_address
}