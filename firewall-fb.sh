#!/usr/bin/env bash
#
# Performs the required firewall configurations
#
# Filename: firewall-fb.sh
#
# Variables: $sshPort
#
source ./custom-variables-fb.var

# Change SSH port and allow HTTP and FTP traffic internally for libvirt VMs
firewall-cmd --permanent --add-port=$sshPort/tcp
firewall-cmd --permanent --remove-service=ssh
firewall-cmd --permanent --add-service=ftp --zone=internal 
firewall-cmd --permanent --add-service=http --zone=internal 
firewall-cmd --permanent --add-interface=virbr0 --zone=internal
firewall-cmd --permanent --add-interface=virbr1 --zone=internal