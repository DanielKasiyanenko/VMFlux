#!/bin/bash

error() {
        if [ $? -ne 0 ]; then
                printf "\n\ndnf failed...\n\n";
                exit 1
        fi
}

# Check whether the install media is mounted, and if necessary mount it.
if [ ! -d /mnt/BaseOS/ ] || [ ! -d /mnt/AppStream/ ]; then
  mount /dev/cdrom /mnt || (printf "\nFailed mount RHEL cdrom.\n"; exit 1)
fi

# Close a potential security hole.
systemctl disable remote-fs.target

# Disable kernel dumping.
systemctl disable kdump.service

# Remove cockpit firewall exception.
firewall-cmd --permanent --zone=public --remove-service=cockpit &>/dev/null || echo >/dev/null

# Setup the python path and increase the history size.
printf "export HISTSIZE=\"100000\"\n" > /etc/profile.d/histsize.sh
chcon "system_u:object_r:bin_t:s0" /etc/profile.d/histsize.sh
chmod 644 /etc/profile.d/histsize.sh
