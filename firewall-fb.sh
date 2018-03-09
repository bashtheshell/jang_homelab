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
firewall-cmd --permanent --add-interface=virbr0 --zone=public
firewall-cmd --permanent --add-interface=virbr1 --zone=public
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.122.0/24" service name="ftp" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.122.0/24" service name="http" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.100.0/24" service name="ftp" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.100.0/24" service name="http" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.100.50" service name="ntp" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.122.50" service name="ntp" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.100.50" service name="dns" accept'
