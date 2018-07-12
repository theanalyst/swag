provider "openstack" {}

resource "openstack_networking_floatingip_v2" "admin_fip" {
  pool = "floating"
}

resource "openstack_compute_keypair_v2" "deploy_key" {
  name       = "deploy_key"
  public_key = "${var.deploy_key}"
}

resource "openstack_networking_network_v2" "storage_net" {
  name           = "${var.vm_name_prefix}_storage_net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "storage_subnet" {
  name       = "${var.vm_name_prefix}_storage_subnet"
  network_id = "${openstack_networking_network_v2.storage_net.id}"
  cidr       = "${var.storage_subnet_cidr}"
  ip_version = 4
}

resource "openstack_networking_network_v2" "external_net" {
  name           = "${var.vm_name_prefix}_external_net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "external_subnet" {
  name       = "${var.vm_name_prefix}_external_subnet"
  network_id = "${openstack_networking_network_v2.external_net.id}"
  cidr       = "${var.external_subnet_cidr}"
  ip_version = 4
}

resource "openstack_networking_router_v2" "external_router" {
  name                = "${var.vm_name_prefix}_ext_router"
  admin_state_up      = "true"
  external_network_id = "${var.external_network_id}"
}

resource "openstack_networking_router_interface_v2" "ext_int" {
  router_id = "${openstack_networking_router_v2.external_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.external_subnet.id}"
}

data "template_file" "common_config" {
  template = "${file("common-bootstrap.tpl")}"
  vars {
    ssh_keys = "${var.ssh_keys}"
  }
}

resource "openstack_compute_instance_v2" "admin" {
  name            = "${var.vm_name_prefix}-admin"
  key_pair        = "${openstack_compute_keypair_v2.deploy_key.name}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.admin_flavor}"
  security_groups = ["default"]

  network {
    uuid        = "${openstack_networking_network_v2.external_net.id}"
    fixed_ip_v4 = "${cidrhost(var.external_subnet_cidr, 10)}"
  }

  network {
    uuid        = "${openstack_networking_network_v2.storage_net.id}"
    fixed_ip_v4 = "${cidrhost(var.storage_subnet_cidr, 10)}"
  }

  user_data = "${data.template_file.common_config.rendered}"
}

resource "openstack_compute_floatingip_associate_v2" "admin_fip" {
  floating_ip = "${openstack_networking_floatingip_v2.admin_fip.address}"
  instance_id = "${openstack_compute_instance_v2.admin.id}"
  fixed_ip = "${cidrhost(var.external_subnet_cidr, 10)}"
}

resource "openstack_blockstorage_volume_v2" "osds" {
  count = "${var.osds_per_vm * (var.mon_count + var.st_count)}"
  size  = "${var.osd_size}"
}

resource "openstack_compute_instance_v2" "stmon" {
  count           = "${var.mon_count}"
  name            = "${var.vm_name_prefix}-stmon-${count.index}"
  key_pair        = "${openstack_compute_keypair_v2.deploy_key.name}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.mon_flavor}"
  security_groups = ["default"]

  network {
    uuid        = "${openstack_networking_network_v2.external_net.id}"
    fixed_ip_v4 = "${cidrhost(var.external_subnet_cidr, 10)}"
  }

  network {
    uuid        = "${openstack_networking_network_v2.storage_net.id}"
    fixed_ip_v4 = "${cidrhost(var.storage_subnet_cidr, count.index + 20)}"
  }

  user_data = "${data.template_file.common_config.rendered}"
}

resource "openstack_compute_volume_attach_v2" "stmon-osd-attach" {
  count       = "${var.mon_count * var.osds_per_vm}"
  instance_id = "${element(openstack_compute_instance_v2.stmon.*.id, count.index / var.osds_per_vm)}"
  volume_id   = "${element(openstack_blockstorage_volume_v2.osds.*.id, count.index)}"
}

output "external_ip" {
  value = "${openstack_networking_floatingip_v2.admin_fip.address}"
}

resource "openstack_compute_instance_v2" "st" {
  count           = "${var.mon_count}"
  name            = "${var.vm_name_prefix}-stmon-${count.index}"
  key_pair        = "${openstack_compute_keypair_v2.deploy_key.name}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.mon_flavor}"
  security_groups = ["default"]

  network {
    uuid        = "${openstack_networking_network_v2.external_net.id}"
    fixed_ip_v4 = "${cidrhost(var.external_subnet_cidr, 10)}"
  }

  network {
    uuid        = "${openstack_networking_network_v2.storage_net.id}"
    fixed_ip_v4 = "${cidrhost(var.storage_subnet_cidr, count.index + 100)}"
  }

  user_data = "${data.template_file.common_config.rendered}"
}

resource "openstack_compute_volume_attach_v2" "st-osd-attach" {
  count       = "${var.st_count * var.osds_per_vm}"
  instance_id = "${element(openstack_compute_instance_v2.stmon.*.id, count.index / var.osds_per_vm)}"
  volume_id   = "${element(openstack_blockstorage_volume_v2.osds.*.id, count.index)}"
}
