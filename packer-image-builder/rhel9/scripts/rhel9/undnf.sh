#!/bin/bash
set -euxo pipefail

# Remove DNF/YUM cache
dnf clean all

# Remove package manager logs
rm -rf /var/cache/dnf /var/cache/yum
rm -f /var/log/{dnf,yum}.log

# Remove dnf history
rm -rf /var/lib/dnf/history.*

# Remove persistent network rules
rm -f /etc/udev/rules.d/70-persistent-net.rules

# Reset machine-id
truncate -s 0 /etc/machine-id

# Remove SSH host keys
rm -f /etc/ssh/ssh_host_*

# Clean temp directories
rm -rf /tmp/* /var/tmp/*

# Remove shell history
rm -f /root/.bash_history

# Remove local repo
rm -f /etc/yum.repos.d/local.repo
echo "Cleanup completed successfully."
