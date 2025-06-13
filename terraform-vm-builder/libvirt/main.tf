#main.tf
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

#Storage pool
#resource "libvirt_pool" "rhel9_pool" {
#  name = "rhel9-secureboot-pool"
#  type = "dir"
#  path = "/var/lib/libvirt/images/rhel9secureboot"
#}

# Base image (original source)
resource "libvirt_volume" "base_image_source" {
  name   = "rhel9-base-source"
  pool   = "rhel9-secureboot-pool"
  source = "/home/daniel/packer-image-builder/rhel9/output/rhel9-5-libvirt-x64-efi-/rhel9-5-libvirt-x64-efi"
}

# Resizable volume using base image
resource "libvirt_volume" "base_image" {
  name           = "rhel9-secureboot"
  pool           = "rhel9-secureboot-pool"
  base_volume_id = libvirt_volume.base_image_source.id
  size           = 21474836480  # 20GB in bytes
}

#Cloud disk
resource "libvirt_cloudinit_disk" "commoninit" {
  name       = "commoninit.iso"
  pool       = "rhel9-secureboot-pool"
# depends_on = [libvirt_pool.rhel9_pool]
  user_data  = templatefile("${path.module}/cloud-init.cfg", {})
  meta_data  = jsonencode({instance-id = uuid()})
  network_config = templatefile("${path.module}/network_config.cfg", {})
  lifecycle {
    ignore_changes = [name]  # Preserve name but allow content updates
  }
}

# VM Domain
resource "libvirt_domain" "rhel9_secure" {
  name      = "rhel9-secureboot"
  memory    = "8192"
  vcpu      = 2
  autostart = false
  qemu_agent = true

  # UEFI Configuration
  firmware  = "/usr/share/OVMF/OVMF_CODE_4M.secboot.fd"
  machine   = "q35"
  nvram {
    file     = "/var/lib/libvirt/images/rhel9-secureboot/efivars.fd"
    template = "/usr/share/OVMF/OVMF_VARS_4M.ms.fd"
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  xml {
    xslt = file("libvirt-domain.xsl")
  }
  cpu {
    mode = "host-passthrough"
  }
 
  disk {
    volume_id = libvirt_volume.base_image.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
    #source_path = "/dev/pts/4"
  }

  video {
    type = "virtio"
  }
  network_interface {
    network_name   = "terraform"
    hostname       = "rhel9-secureboot"
    wait_for_lease = false    
  }
}
