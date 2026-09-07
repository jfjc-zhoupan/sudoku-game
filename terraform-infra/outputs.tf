output "vm_public_ip" {
  description = "The public IP address of the VM"
  value       = module.network-webapp.public_ip_address
}

output "admin_username" {
  description = "The admin user of the VM"
  value       = "zhou"
}

