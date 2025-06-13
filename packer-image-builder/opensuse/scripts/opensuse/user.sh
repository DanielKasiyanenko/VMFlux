#!/bin/bash

# Setup sudo for the packer user
if ! grep -q '^packer:' /etc/passwd; then
  useradd -m -s /bin/bash packer
  echo "packer:packer" | chpasswd
  usermod -aG wheel packer
fi

# Configure sudo
echo "packer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/packer
chmod 0440 /etc/sudoers.d/packer
