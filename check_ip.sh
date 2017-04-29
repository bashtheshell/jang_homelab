#!/usr/bin/env bash
#
# This script updates the file if the public IP address has changed and 
# sends notification via email if change has occurred
#
# Filename: check_ip.sh
#

# Your email address 
yourEmail=YOUREMAILADDRESS

# Initialze variable
ipaddr=""


# If there is a change, then update the current address and send change notification
if [[ $(cat ~/current_public_ip.txt) = $(curl -4s http://www.icanhazip.com) ]]
then
        logger -p local0.info "No change to public IP address"
else
        ipaddr=$(curl -4s http://www.icanhazip.com)
        echo "Your public IP address has changed to $ipaddr" | mail -s "Change to Your Public IP" $yourEmail
        echo $ipaddr > ~/current_public_ip.txt
        logger -p local0.notice "The public IP address has changed to $ipaddr"
fi
