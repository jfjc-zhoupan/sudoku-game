variable location {}
variable rg_name {}
variable vm_name {}
variable vm_size {}
variable admin_username {}
variable nic_id {}
variable public_key {
    sensitive = true
}
variable env_tag {}
variable user_data_script {
    default = ""
}
variable "docker_user" {
    sensitive = true
}
variable "docker_pass" {
    sensitive = true
}