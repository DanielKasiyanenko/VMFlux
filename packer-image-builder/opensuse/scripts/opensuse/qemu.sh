#!/bin/bash

error() {
    if [ $? -ne 0 ]; then
        printf "\n\nqemu addons failed to install...\n\n"
        exit 1
    fi
}

echo "Starting QEMU Guest Agent installation..."

# Install dependencies from openSUSE repositories
echo "Installing required packages..."
zypper --non-interactive install dmidecode qemu-guest-agent
error

# Verify virtualization environment
if [[ "$(dmidecode -s system-product-name)" != "KVM" && "$(dmidecode -s system-manufacturer)" != "QEMU" ]]; then
    echo "Not running on QEMU/KVM. Exiting."
    exit 0
fi

# Configure services
echo "Enabling and starting services..."
systemctl enable qemu-guest-agent
systemctl start qemu-guest-agent
systemctl enable --now serial-getty@ttyS0.service

echo "QEMU Guest Agent installation completed successfully."
