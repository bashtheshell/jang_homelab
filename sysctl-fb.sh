#!/usr/bin/env bash
#
# This script modifies the kernel runtime parameter to block ICMP ping request.
#
# Filename: sysctl-fb.sh
#

echo "net.ipv4.icmp_echo_ignore_all = 1" >> /etc/sysctl.conf
echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

