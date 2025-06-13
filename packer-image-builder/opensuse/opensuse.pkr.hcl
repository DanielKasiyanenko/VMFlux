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

source "qemu" "opensuse-leap15-6-libvirt-x64-efi" {
  vm_name                = "opensuse-leap15-6-libvirt-x64-efi"
  output_directory       = "output/opensuse-leap15-6-libvirt-x64-efi-${var.box_version}"
  qemu_binary            = "qemu-system-x86_64"
  boot_wait              = "10s"
  boot_keygroup_interval = "1s"
boot_command = [
  "c<wait> autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/autoinst.xml <enter>boot<enter>"]
  qemuargs = [
    ["-device", "virtio-serial"],
    ["-chardev", "socket,id=char0,path=/tmp/qga.sock,server=on,wait=off"],
    ["-device", "virtserialport,chardev=char0,name=org.qemu.guest_agent.0"],
    ["-device", "virtio-scsi-pci,id=scsi0"],
    ["-device", "scsi-hd,drive=drive0,bus=scsi0.0"],
    ["-display", "none"]
  ]
  efi_firmware_code    = "/usr/share/OVMF/OVMF_CODE_4M.secboot.fd" 
  efi_firmware_vars    = "OVMF/OVMF_VARS_4M.ms.fd"
  efi_drop_efivars     = true
  format               = "qcow2"
  accelerator          = "kvm"
  machine_type         = "q35"
  disk_interface       = "virtio-scsi"
  disk_cache           = "none"
  disk_detect_zeroes   = "on"
  disk_size            = "4096"
  disk_image           = false
  net_device           = "virtio-net"
  net_bridge           = "virbr0"
  cpus                 = 4
  cpu_model            = "host"
  memory               = 4096
  http_directory       = "http"
  headless             = false
  iso_url              = "isos/openSUSE-Leap-15.6-DVD-x86_64-Media.iso"
  iso_checksum         = "sha256:a74d4072e639c75ca127df3d869c1e57bcc44a093a969550f348a3ead561fe4f"
  communicator         = "ssh"
  ssh_username         = "root"
  ssh_password         = "packer"
  ssh_port             = 2222
  host_port_min        = 2222
  host_port_max        = 2222
  ssh_handshake_attempts = 1000
  vnc_bind_address     = "0.0.0.0"
  vnc_port_min         = "9000"
  vnc_port_max         = "9000"
  ssh_timeout          = "3600s"
  shutdown_command     = "shutdown -P now"
}

build {
  sources = ["source.qemu.opensuse-leap15-6-libvirt-x64-efi"]

  provisioner "shell" {
    execute_command     = "{{ .Vars }} /bin/bash '{{ .Path }}'"
    expect_disconnect   = true
    scripts             = [
      "scripts/opensuse/network.sh",
      "scripts/opensuse/zypper.sh",
      "scripts/opensuse/base.sh",
      "scripts/opensuse/reboot.sh"
    ]
    start_retry_timeout = "15m"
    timeout             = "2h0m0s"
  }

  provisioner "shell" {
    execute_command     = "{{ .Vars }} /bin/bash '{{ .Path }}'"
    expect_disconnect   = true
    pause_before        = "30s"
    scripts             = [
      "scripts/opensuse/kernel.sh",
      "scripts/opensuse/floppy.sh",
      "scripts/opensuse/qemu.sh",
      "scripts/opensuse/user.sh",
      "scripts/opensuse/sshd.sh",
      "scripts/opensuse/cleanup.sh",
      "scripts/opensuse/undnf.sh"

    ]
    start_retry_timeout = "15m"
    timeout             = "2h0m0s"
  }

  post-processor "checksum" {
    keep_input_artifact = false
    checksum_types      = ["sha256"]
    output              = "output/opensuse-leap15-6-libvirt-x64-efi-${var.box_version}/${source.name}-${var.box_version}.qcow2.sha256"
  }
}
