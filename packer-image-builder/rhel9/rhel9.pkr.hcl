packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
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

variable "box_version" {
  type    = string
  default = env("VERSION")
}
# QEMU builder for RHEL 9 with UEFI Secure Boot
source "qemu" "rhel9-5-libvirt-x64-efi" {
  vm_name                = "rhel9-5-libvirt-x64-efi"
  output_directory       = "output/rhel9-5-libvirt-x64-efi-${var.box_version}"
  qemu_binary            = "qemu-system-x86_64"
  boot_wait              = "10s"
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
  iso_url                = "isos/rhel-9.5-x86_64-dvd.iso"
  iso_checksum           = "sha256:0bb7600c3187e89cebecfcfc73947eb48b539252ece8aab3fe04d010e8644ea9"
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
        "<wait30>c<wait>linuxefi /images/pxeboot/vmlinuz inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel9.ks",
         " inst.stage2=cdrom inst.repo=cdrom inst.disk=/dev/vda net.ifnames=0 biosdevname=0",
         "<enter>initrdefi /images/pxeboot/initrd.img <enter>boot <enter>"
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
  sources = ["source.qemu.rhel9-5-libvirt-x64-efi"]

  # Provisioning scripts
  provisioner "shell" {
    execute_command     = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    expect_disconnect   = true
    scripts             = [
      "scripts/rhel9/network.sh",
      "scripts/rhel9/dnf.sh",
      "scripts/rhel9/base.sh",
      "scripts/rhel9/reboot.sh"
    ]
    start_retry_timeout = "15m"
    timeout             = "2h0m0s"
  }

  provisioner "shell" {
    execute_command     = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    expect_disconnect   = true
    pause_before        = "30s"
    scripts             = [
      "scripts/rhel9/kernel.sh",
      "scripts/rhel9/floppy.sh",
      "scripts/rhel9/qemu.sh",
      "scripts/rhel9/user.sh",
      "scripts/rhel9/sshd.sh",
      "scripts/rhel9/undnf.sh",
      "scripts/rhel9/cleanup.sh"
    ]
    start_retry_timeout = "15m"
    timeout             = "2h0m0s"
  }

  # Checksum post-processing
  post-processor "checksum" {
    keep_input_artifact = false
    checksum_types      = ["sha256"]
    output              = "output/rhel9-5-libvirt-x64-efi-${var.box_version}/${source.name}-${var.box_version}.qcow2.sha256"
  }
}

