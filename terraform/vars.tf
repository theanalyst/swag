variable "vm_name_prefix" {
  default = "ses-war-games"
}

variable "admin_flavor" {
  default = "m1.medium"
}

variable "mon_flavor" {
  default = "m1.medium"
}

variable "mon_count" {
  default = 3
}

variable "st_count" {
  default = 2
}

variable "osds_per_vm" {
  default = 4
}

variable "osd_size" {
  default = 20
}

variable "deploy_key" {}

variable "storage_subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "external_network_id" {}

variable "external_subnet_cidr" {
  default = "10.1.0.0/24"
}

variable "image_name" {
  default = "openSUSE-Leap-42.3-OpenStack.x86_64"
}

variable "ssh_keys" {
  default = ""
}
