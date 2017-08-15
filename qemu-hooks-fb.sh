#!/usr/bin/env bash
#
# This script will enable VMs to communicate with each other due to default NAT restriction
# implemented by libvirt. This script should be in '/etc/libvirt/hooks' directory with its 
# filename being 'qemu'.
#
# Filename: qemu-hooks-fb.sh
#


# Set the guest name here (as defined in the libvirt domain XML)
GNAME=""
GUEST_IP=""
VIRNET=""

case "${1}" in
	"server1.example.com")
		GNAME=server1.example.com
		GUEST_IP=192.168.122.50
		VIRNET="virbr0"
		;;

	"tester1.example.com")
		GNAME=tester1.example.com
		GUEST_IP=192.168.122.150
		VIRNET="virbr0"
		;;

	"outsider1.example.org")
		GNAME=outsider1.example.org
		GUEST_IP=192.168.100.100
		VIRNET="virbr1"	
		;;
	
	"clone1.example.org")
		GNAME=clone1.example.org
		GUEST_IP=192.168.100.50
		VIRNET="virbr1"
		;;

	*)
		logger "Unidentifed VM was used in libvirt QEMU hook script. [ $(date) ]"
esac


if [ "${1}" = "$GNAME" ]; then

   # If VM is power off, remove rule from iptables FORWARD chain
   if [ "${2}" = "stopped" ] || [ "${2}" = "reconnect" ]; then
        /sbin/iptables -D FORWARD -o $VIRNET -d  $GUEST_IP -j ACCEPT
   fi


   # If VM is started, insert rule on top of the iptables FORWARD chain
   if [ "${2}" = "start" ] || [ "${2}" = "reconnect" ]; then
        /sbin/iptables -I FORWARD -o $VIRNET -d  $GUEST_IP -j ACCEPT
   fi
fi