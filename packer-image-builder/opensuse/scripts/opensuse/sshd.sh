#!/bin/bash

# Enable PasswordAuthentication
sed -i 's/^#*PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Enable root login
sed -i 's/^#*PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config

# Restart sshd service
systemctl restart sshd
