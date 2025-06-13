#!/bin/bash -eux

# Enable debug tracing
set -x
exec >/var/log/apt-init.log 2>&1

# Debug: Show initial sources.list
echo "### Initial APT sources ###" > /var/log/apt-sources-debug.log
cat /etc/apt/sources.list >> /var/log/apt-sources-debug.log

# Clean CD-ROM references first
echo "Cleaning CD-ROM sources..."
sed -i '/cdrom:/d' /etc/apt/sources.list

# Debug: Show modified sources.list
echo "### Modified APT sources ###" >> /var/log/apt-sources-debug.log
cat /etc/apt/sources.list >> /var/log/apt-sources-debug.log

# Update with debug output
echo "Starting apt-get update..."
apt-get update -y -o Debug::pkgAcquire=1 -o Debug::pkgAutoRemove=1

# Install packages with version logging
echo "Installing base packages..."
apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  sudo \
  vim-tiny \
  locales \
  net-tools 2>&1 | tee /var/log/package-installs.log

# Debug: Show installed package versions
echo "### Installed versions ###" >> /var/log/package-installs.log
dpkg -l ca-certificates curl sudo vim-tiny locales net-tools >> /var/log/package-installs.log
