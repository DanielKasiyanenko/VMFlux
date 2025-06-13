#!/bin/bash

# Remove temporary files
rm -rf /tmp/*
rm -f /var/log/wtmp /var/log/btmp
history -c

# Clean the package cache
zypper clean --all
