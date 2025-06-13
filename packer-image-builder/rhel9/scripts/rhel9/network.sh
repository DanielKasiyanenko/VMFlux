#!/bin/bash

# Set the hostname, and then ensure it will resolve properly.
printf "rhel9.localdomain\n" > /etc/hostname
printf "\n127.0.0.1 rhel9.localdomain\n\n" >> /etc/hosts
