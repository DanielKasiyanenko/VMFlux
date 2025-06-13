#!/bin/bash -eux

# Set hostname
echo "debian" > /etc/hostname
echo "127.0.0.1 debian" >> /etc/hosts

# Configure network interfaces for predictable naming
cat <<EOF > /etc/systemd/network/10-eth0.network
[Match]
Name=eth0

[Network]
DHCP=yes
EOF

# Enable systemd-networkd
systemctl enable systemd-networkd

# Disable cloud-init network config if installed
if [ -f /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg ]; then
  echo "network: {config: disabled}" > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
fi

# Install QEMU guest agent
apt-get install -y qemu-guest-agent
systemctl enable qemu-guest-agent
