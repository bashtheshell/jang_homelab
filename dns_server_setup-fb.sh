#!/usr/bin/env bash
#
# Set up a caching DNS server only for the guest VMs
#
# Filename: dns_server_setup-fb.sh
#
# Variables: $netIP, 
#
source ./custom-variables-fb.var


# Configure DNS to serve the VM host:
sed -i "s/listen-on port 53 { 127.0.0.1;/listen-on port 53 { 127.0.0.1; ${netIP};/" /etc/named.conf
sed -i "s/allow-query     { localhost;/allow-query     { localhost; 192.168.100.50;/" /etc/named.conf


# Enable and restart the DNS server:
systemctl enable named.service
systemctl restart named.service