variable location {}
variable public_key_path {}
variable user_data_script {
    default = ""
}
variable "docker_user" {
    sensitive = true
}
variable "docker_pass" {
    sensitive = true
}