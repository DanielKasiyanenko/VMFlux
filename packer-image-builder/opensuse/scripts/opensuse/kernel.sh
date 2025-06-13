#!/bin/bash -eux

echo "Installing kernel development packages..."
zypper --non-interactive install kernel-default-devel kernel-source kernel-syms

echo "Cleaning old kernels..."
current_kernel=$(uname -r)
zypper --non-interactive remove $(rpm -q kernel-default | grep -v "$current_kernel")
