#!/usr/bin/env bash
#
# This script will deny any service using tcpwrapper except SSH and FTP servers
#
# Filename: tcpwrapper-fb.sh
#

echo "ALL:ALL" >> /etc/hosts.deny
echo "sshd:ALL" >> /etc/hosts.allow
echo "vsftpd:ALL" >> /etc/hosts.allow

