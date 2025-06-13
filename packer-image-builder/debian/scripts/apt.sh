#!/bin/bash -eux

# Configure APT
cat <<EOF > /etc/apt/apt.conf.d/99custom
APT::Install-Recommends "false";
APT::Install-Suggests "false";
APT::AutoRemove::RecommendsImportant "false";
APT::AutoRemove::SuggestsImportant "false";
EOF

# Update apt sources to use https
apt-get install -y apt-transport-https gnupg

# Clean APT cache
apt-get autoremove -y
apt-get clean

# Remove APT lists to save space
rm -rf /var/lib/apt/lists/*

# Configure automatic updates with unattended-upgrades
apt-get update
apt-get install -y unattended-upgrades

cat <<EOF > /etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Allowed-Origins {
  "\${distro_id}:\${distro_codename}";
  "\${distro_id}:\${distro_codename}-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
EOF
