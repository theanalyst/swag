provider "openstack" {}

resource "openstack_networking_floatingip_v2" "admin_fip" {
  pool = "floating"
}

resource "openstack_compute_keypair_v2" "deploy_key" {
  name = "deploy_key"
  public_key = "${var.deploy_key}"
}

resource "openstack_compute_instance_v2" "admin" {
  count           = 1
  name            = "${var.vm_name_prefix}-admin"
  key_pair        = "${openstack_compute_keypair_v2.deploy_key.name}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.admin_flavor}"
  security_groups = ["default"]

  network {
    name = "fixed"
  }
}

resource "openstack_compute_floatingip_associate_v2" "admin_fip" {
  floating_ip = "${openstack_networking_floatingip_v2.admin_fip.address}"
  instance_id = "${openstack_compute_instance_v2.admin.id}"
}
