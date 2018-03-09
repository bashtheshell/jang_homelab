#!/usr/bin/env bash
#
# Set up the NTP server for two guest VMs
#
# Filename: ntp_server_setup-fb.sh
#

# Append the configuration:
echo " " >> /etc/chrony.conf
echo "# CUSTOM SETTINGS:" >> /etc/chrony.conf
echo "allow 192.168.122.50" >> /etc/chrony.conf
echo "allow 192.168.100.50" >> /etc/chrony.conf
echo "local stratum 10" >> /etc/chrony.conf

# Enable and restart the service
systemctl enable chronyd.service
systemctl restart chronyd.service