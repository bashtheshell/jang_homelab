#!/usr/bin/env bash
#
# Modify the default SElinux port context for SSH
#
# Filename: ssh-selinux-port-fb.sh
#
# Variables: $sshPort
#
source ./custom-variables-fb.var

semanage port -a -t ssh_port_t -p tcp $sshPort

