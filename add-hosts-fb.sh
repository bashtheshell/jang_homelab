#!/usr/bin/env bash
#
# Add all hosts' names and their ip addresses to 'hosts' file
#
# Filename: add-hosts-fb.sh
#
# Variables: $netFQDN, $netIP
#
source ./custom-variables-fb.var

# Get only the hostname from the FQDN
netHostname=$(echo $netFQDN | awk -F. '{ print $1 }')

echo -e \
"$netIP $netFQDN $netHostname\n\
192.168.122.50 server1.example.com server1\n\
192.168.122.150 tester1.example.com tester1\n\
192.168.100.100 outsider1.example.org outsider1\n\
192.168.100.50 clone1.example.org clone1" >> /etc/hosts

