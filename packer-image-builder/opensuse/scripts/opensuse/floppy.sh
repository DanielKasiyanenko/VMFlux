#!/bin/bash

printf 'blacklist floppy\n' > /etc/modprobe.d/floppy.conf

# Regenerate initramfs for all installed kernels
find /lib/modules -maxdepth 1 -type d | while read -r kernel; do
    kernel_version=$(basename "$kernel")
    dracut -f "/boot/initramfs-${kernel_version}.img" "${kernel_version}"
done
