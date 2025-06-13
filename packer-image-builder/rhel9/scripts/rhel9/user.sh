#!/bin/bash -ux

# Enable exit/failure on error.
set -eux

if [ -d /etc/polkit-1/rules.d/ ]; then
cat <<-EOF > /etc/polkit-1/rules.d/49-packer.rules
polkit.addRule(function(action, subject) {
    if (subject.isInGroup("packer")) {
        return polkit.Result.YES;
    }
});
EOF
chmod 0440 /etc/polkit-1/rules.d/49-packer.rules
chmod 0440 /etc/sudoers.d/packer
fi

# Mark the packer box build time.
date --utc > /etc/packer_box_build_time
