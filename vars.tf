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

variable "osds_per_vm" {
  default = 4
}

variable "osd_size" {
  default = 20
}
variable "deploy_key" {}

variable "image_name" {
  default = "openSUSE-Leap-42.3-OpenStack.x86_64"
}
