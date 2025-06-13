#!/bin/bash

# Close a potential security hole
systemctl disable remote-fs.target

# Disable kernel dumping if available
if systemctl list-unit-files | grep -q kdump.service; then
  systemctl disable kdump.service
fi

# Setup increased history size
printf "export HISTSIZE=\"100000\"\n" > /etc/profile.d/histsize.sh
chmod 644 /etc/profile.d/histsize.sh
