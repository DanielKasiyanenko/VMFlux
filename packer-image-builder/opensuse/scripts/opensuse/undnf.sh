#!/bin/bash

# Unmount and eject the openSUSE DVD
(umount /dev/cdrom && eject /dev/cdrom) || printf "\nThe openSUSE DVD isn't mounted.\n"

# If Parallels has mounted the user home directory, don't remove it
if [ -d /media/psf/Home/ ]; then
  umount /media/psf/Home/
fi

# Remove any installation media mount points and directories
if [ -d /var/adm/mount ]; then
  rm --force --recursive /var/adm/mount/*
fi

# Remove any DVD repository configurations
if [ -f /etc/zypp/repos.d/dvd.repo ]; then
  rm --force /etc/zypp/repos.d/dvd.repo
fi

# Remove any installation media from repository list
zypper removerepo --all dvd || true
zypper removerepo --all cd || true

# Clean up any temporary installation files
if [ -d /var/tmp/YaST2 ]; then
  rm --force --recursive /var/tmp/YaST2/*
fi

# Clean zypper cache to ensure fresh repository metadata
zypper clean --all

# Note: openSUSE doesn't use EPEL repositories, so the EPEL configuration 
# commands from the original script have been removed
