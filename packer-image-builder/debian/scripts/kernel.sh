#!/bin/bash -eux

# Install latest kernel and headers
apt-get update
apt-get install -y linux-image-amd64 linux-headers-amd64

# Configure kernel parameters
cat <<EOF > /etc/sysctl.d/99-packer.conf
# Optimize for virtualization
vm.swappiness = 10
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_timestamps = 0
EOF

# Update initramfs with optimized settings
cat <<EOF > /etc/initramfs-tools/modules
# Virtio modules
virtio
virtio_pci
virtio_net
virtio_blk
virtio_scsi
EOF

# Regenerate initramfs
update-initramfs -u -k all

# Remove any old kernels if multiple exist
kernelver=$(uname -r)
if dpkg -l | grep -q linux-image | grep -v "$kernelver"; then
  apt-get purge -y $(dpkg -l | grep linux-image | grep -v "$kernelver" | awk '{print $2}')
fi
