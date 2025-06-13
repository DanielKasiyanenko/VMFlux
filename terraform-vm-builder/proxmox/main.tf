terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.70.0"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://192.168.1.110:8006/"
  username  = "root@pam"
  password  = "XXXX"
  insecure  = true
}

# 1. Upload QCOW2 image with Secure Boot compatibility
resource "proxmox_virtual_environment_download_file" "rhel9_image" {
  content_type        = "iso"
  datastore_id        = "slow_data"
  node_name           = "proxmox"
  file_name           = "rhel9-secureboot.img"
  url                 = "http://192.168.1.10:8000/rhel9-5-libvirt-x64-efi.qcow2"
  overwrite           = true
}

# 2. Cloud-init configuration
resource "proxmox_virtual_environment_file" "cloudinit" {
  content_type = "snippets"
  datastore_id = "app_pool1"
  node_name    = "proxmox"

  source_raw {
    data      = templatefile("${path.module}/cloud-init.yaml", {})
    file_name = "rhel9-cloudinit.yaml"
  }
  lifecycle {
    ignore_changes = [source_raw[0].data]
  }
}

resource "proxmox_virtual_environment_file" "network_snippet" {
  content_type = "snippets"
  datastore_id = "app_pool1"
  node_name    = "proxmox"
  source_raw {
    data      = file("${path.module}/network_config.yaml")
    file_name = "network_config.yaml"
  }
  lifecycle {
    ignore_changes = [source_raw[0].data]
  }
}


# 3. VM Definition with Secure Boot
resource "proxmox_virtual_environment_vm" "rhel9_secure" {
  name        = "rhel9-secureboot"
  node_name   = "proxmox"
  vm_id       = 222
  on_boot     = false

  # UEFI/Secure Boot Configuration
  bios        = "ovmf"
  machine     = "q35"
  efi_disk {
    datastore_id = "slow_data"
    file_format  = "raw"
    type         = "4m"
    pre_enrolled_keys = true
  }

  # Hardware Configuration
  cpu {
    cores   = 2
    type    = "host"
  }
  agent {
    enabled = true
  }
  memory {
    dedicated = 4096
  }
  serial_device {}
  
  # Disk Configuration
  disk {
    datastore_id = "slow_data"
    file_id      = proxmox_virtual_environment_download_file.rhel9_image.id
    interface    = "virtio0"
    file_format  = "qcow2"
    size         = 20
  }
 
  # Network Configuration
  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }
  # Cloud-init initialization (bpg)
  initialization {
    user_data_file_id = proxmox_virtual_environment_file.cloudinit.id
    network_data_file_id = proxmox_virtual_environment_file.network_snippet.id
    interface = "scsi1"
  }
}
