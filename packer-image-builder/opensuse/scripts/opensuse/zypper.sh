#!/bin/bash

# Setup the repositories for openSUSE Leap
zypper addrepo -f http://download.opensuse.org/distribution/leap/15.6/repo/oss/ oss
zypper addrepo -f http://download.opensuse.org/distribution/leap/15.6/repo/non-oss/ non-oss
zypper addrepo -f http://download.opensuse.org/update/leap/15.6/oss/ update-oss
zypper addrepo -f http://download.opensuse.org/update/leap/15.6/non-oss/ update-non-oss

# Refresh repository information
zypper --gpg-auto-import-keys refresh

# Install basic packages
zypper --non-interactive install sudo dmidecode bash-completion man man-pages vim sysstat bind-utils wget tar telnet net-tools coreutils grep gawk sed curl patch make gcc python3 rsync cloud-init
