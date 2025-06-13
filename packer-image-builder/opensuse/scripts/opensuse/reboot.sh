#!/bin/bash

printf "Updates have been applied.\n"
printf "Rebooting onto the newly installed kernel. Yummy.\n"

# Schedule a reboot
( shutdown --reboot --no-wall +1 ) &
exit 0
