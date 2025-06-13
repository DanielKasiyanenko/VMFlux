#!/bin/bash
set -eux

# Install signed bootloader packages
apt-get update
apt-get install -y shim-signed systemd-boot-efi-amd64-signed

# Install systemd-boot to EFI partition
bootctl install --path=/boot/efi

# Optionally, verify Secure Boot status
mokutil --sb-state || true
