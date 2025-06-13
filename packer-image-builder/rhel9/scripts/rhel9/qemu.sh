#!/bin/bash

error() {
    if [ $? -ne 0 ]; then
        printf "\n\nqemu addons failed to install...\n\n"
        exit 1
    fi
}

echo "Starting QEMU Guest Agent installation..."

# Check if running on QEMU/KVM
if [[ "$(dmidecode -s system-product-name)" != "KVM" && "$(dmidecode -s system-manufacturer)" != "QEMU" ]]; then
    echo "Not running on QEMU/KVM. Exiting."
    exit 0
fi

# Enable The Qemu Guest Agent
echo "Enabling qemu guest agent."
systemctl enable qemu-guest-agent

# Enable virsh console access
echo "Enabling serial tty."
systemctl enable serial-getty@ttyS0.service

echo "QEMU Guest Agent installation completed successfully."
