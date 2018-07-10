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

resource "openstack_blockstorage_volume_v2" "osds" {
  count = "${var.osds_per_vm * var.mon_count}"
  size = "${var.osd_size}"
}

resource "openstack_compute_instance_v2" "stmon" {
  count = "${var.mon_count}"
  name = "${var.vm_name_prefix}-stmon-${count.index}"
  image_name = "${var.image_name}"
  flavor_name = "${var.mon_flavor}"
  security_groups = ["default"]
  network {
    name="fixed"
  }

}

resource "openstack_compute_volume_attach_v2" "stmon-osd-attach" {
  count = "${var.mon_count * var.osds_per_vm}"
  instance_id = "${element(openstack_compute_instance_v2.stmon.*.id, count.index / var.osds_per_vm)}"
  volume_id = "${element(openstack_blockstorage_volume_v2.osds.*.id, count.index)}"
}
