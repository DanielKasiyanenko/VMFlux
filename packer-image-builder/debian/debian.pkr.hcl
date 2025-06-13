packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}
variable "HTTPIP" {
  type    = string
  default = "127.0.0.1"
}
variable "HTTPPort" {
  type    = number
  default = 8000
}
variable "http_directory" {
  type    = string
  default = "http"
}
variable "box_version" {
  type    = string
  default = env("VERSION")
}

# QEMU builder for Debian 13 with UEFI Secure Boot
source "qemu" "debian13-uefi-secureboot" {
  vm_name                = "debian-13-amd64"
  output_directory       = "output/debian-13-uefi-${var.box_version}"
  qemu_binary            = "qemu-system-x86_64"
  boot_wait              = "5s"
  boot_keygroup_interval = "2s"
  efi_firmware_code      = "/usr/share/OVMF/OVMF_CODE_4M.secboot.fd"
  efi_firmware_vars      = "OVMF/OVMF_VARS_4M.ms.fd"
  efi_drop_efivars       = true
  format                 = "qcow2"
  accelerator            = "kvm"
  machine_type           = "q35"
  disk_interface         = "virtio-scsi"
  disk_cache             = "none"
  disk_detect_zeroes     = "on"
  disk_size              = "4096"
  disk_image             = false
  net_device             = "virtio-net"
  net_bridge             = "virbr0"
  cpus                   = 4
  cpu_model              = "host"
  memory                 = 4096
  http_directory         = "http"
  headless               = false
  iso_checksum           = "sha256:637eabc762d359d6b2b2796e1ed459208fa0ca3f33dc806a95741182af6a4316"
  iso_url                = "isos/debian-trixie-DI-rc1-amd64-DVD-1.iso"
  communicator           = "ssh"
  ssh_username           = "packer"
  ssh_password           = "packer" 
  ssh_port               = 2222
  host_port_min          = 2222
  host_port_max          = 2222
  ssh_handshake_attempts = 1000
  vnc_bind_address       = "0.0.0.0"
  vnc_port_min           = "9000"
  vnc_port_max           = "9000"
  ssh_timeout            = "3600s"
  shutdown_command       = "echo 'packer' | sudo -S shutdown -P now"

# Boot command
boot_command = [
  "<wait20>",
  "c<wait>",
  "linux /install.amd/vmlinuz ",
  "auto=true ",
  "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
  "debian-installer=en_US.UTF-8 ",
  "locale=en_US.UTF-8 ",
  "vga=788 ",
  "noprompt ",
  "quiet ",
  "---<wait>",
  "<enter><wait>",
  "initrd /install.amd/initrd.gz<wait>",
  "<enter><wait>",
  "boot<wait>",
  "<enter><wait>"
  ]
  qemuargs = [
    ["-device", "virtio-serial"],
    ["-chardev", "socket,id=char0,path=/tmp/qga.sock,server=on,wait=off"],
    ["-device", "virtserialport,chardev=char0,name=org.qemu.guest_agent.0"],
    ["-device", "virtio-scsi-pci,id=scsi0"],
    ["-device", "scsi-hd,drive=drive0,bus=scsi0.0"],
    ["-display", "none"]
  ]
}

# Build process
build {
  sources = ["source.qemu.debian13-uefi-secureboot"]

  # Provisioning scripts
  provisioner "shell" {
    execute_command     = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    expect_disconnect   = true
    scripts = [
      "scripts/base.sh",
      "scripts/network.sh",
      "scripts/apt.sh",
      "scripts/kernel.sh",
      "scripts/secureboot.sh"
    ]
  }

  # Checksum post-processing
 post-processor "checksum" {
   keep_input_artifact = false
   checksum_types      = ["sha256"]
   output              = "output/debian-13-amd64-${var.box_version}/debian-13-amd64-${var.box_version}.sha256"
 }
}
