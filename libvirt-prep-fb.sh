#!/usr/bin/env bash
#
# Prepare libvirt for new VMs
#
# Filename: libvirt-prep-fb.sh
#
# Variables: $ssdDrive
#
source ./custom-variables-fb.var


# List of VM hosts to prep for
VMhosts="server1 tester1 outsider1 clone1"


# Clone the "default" network and rename to "outsider"
cp /etc/libvirt/qemu/networks/default.xml /etc/libvirt/qemu/networks/outsider.xml


# Modify the outsider.xml file 
sed -i '/<host/d' /etc/libvirt/qemu/networks/outsider.xml
sed -i 's/<name>.*</<name>outsider</g' /etc/libvirt/qemu/networks/outsider.xml
sed -i '/<uuid>.*<\/uuid>/d' /etc/libvirt/qemu/networks/outsider.xml
sed -i "s/<bridge name='[^']*'/<bridge name='virbr1'/g" /etc/libvirt/qemu/networks/outsider.xml
sed -i '/<mac.*\/>/d' /etc/libvirt/qemu/networks/outsider.xml
sed -i "s/<ip address='[^']*' netmask='[^']*'>/<ip address='192.168.100.1' netmask='255.255.255.0'>/g" /etc/libvirt/qemu/networks/outsider.xml
sed -i "s/<range start='[^']*' end='[^']*'/<range start='192.168.100.128' end='192.168.100.254'/g" /etc/libvirt/qemu/networks/outsider.xml


# Persistently add Outsider network to libvirt
virsh net-define /etc/libvirt/qemu/networks/outsider.xml


# Start and automatically boot up Outsider network
virsh net-autostart outsider
virsh net-start outsider


# Add DHCP clients (server1, tester1) for Default network:
virsh net-update default add ip-dhcp-host "<host mac='00:11:22:33:44:01' ip='192.168.122.50' />" --config --live
virsh net-update default add ip-dhcp-host "<host mac='00:11:22:33:44:11' ip='192.168.122.150' />" --config --live


# Add the DHCP clients (outsider1, clone1) for Outsider network:
virsh net-update outsider add ip-dhcp-host "<host mac='00:11:22:33:44:21' ip='192.168.100.100' />" --config --live
virsh net-update outsider add ip-dhcp-host "<host mac='00:11:22:33:44:31' ip='192.168.100.50' />" --config --live


# Temporarily stop both networks
virsh net-destroy default
virsh net-destroy outsider


# Disable DNS:
sed -i '/<ip.*>$/i\  \<dns enable="no"\/>' /etc/libvirt/qemu/networks/default.xml
sed -i '/<ip.*>$/i\  \<dns enable="no"\/>' /etc/libvirt/qemu/networks/outsider.xml


# Change from 'nat' mode to 'route' mode:
sed -i "s/<forward mode='.*'/<forward mode='route'/" /etc/libvirt/qemu/networks/default.xml
sed -i "s/<forward mode='.*'/<forward mode='route'/" /etc/libvirt/qemu/networks/outsider.xml


# Restart both networks with new modification:
cp /etc/libvirt/qemu/networks/default.xml /etc/libvirt/qemu/networks/default.xml.bkup
cp /etc/libvirt/qemu/networks/outsider.xml /etc/libvirt/qemu/networks/outsider.xml.bkup
virsh net-undefine default
virsh net-undefine outsider
mv /etc/libvirt/qemu/networks/default.xml.bkup /etc/libvirt/qemu/networks/default.xml
mv /etc/libvirt/qemu/networks/outsider.xml.bkup /etc/libvirt/qemu/networks/outsider.xml
virsh net-define /etc/libvirt/qemu/networks/default.xml
virsh net-define /etc/libvirt/qemu/networks/outsider.xml
virsh net-autostart default
virsh net-autostart outsider
virsh net-start default
virsh net-start outsider


# Format 4 more partitions on /dev/sdc drive:
sgdisk -n 2:0:+18G -t 2:8e00 -c 2:"server1 LVM" $ssdDrive
sgdisk -n 3:0:+18G -t 3:8e00 -c 3:"tester1 LVM" $ssdDrive
sgdisk -n 4:0:+18G -t 4:8e00 -c 4:"outsider1 LVM" $ssdDrive
sgdisk -n 5:0:+18G -t 5:8e00 -c 5:"clone1 LVM" $ssdDrive
partprobe $ssdDrive


# Define libvirt storage pool:
virsh pool-define-as server1 logical - - "$ssdDrive"2 server1
virsh pool-define-as tester1 logical - - "$ssdDrive"3 tester1
virsh pool-define-as outsider1 logical - - "$ssdDrive"4 outsider1
virsh pool-define-as clone1 logical - - "$ssdDrive"5 clone1


# Build the defined storage pool:
for server in $VMhosts
do
	virsh pool-build $server
done


# Autostart the storage pool:
for server in $VMhosts
do
	virsh pool-autostart $server
done


# Start the storage pool:
for server in $VMhosts
do
	virsh pool-start $server
done


# Create logical volumes for each pool:
for server in $VMhosts
do
	virsh vol-create-as $server hdd1 16G
	virsh vol-create-as $server hdd2 1G
	virsh vol-create-as $server hdd3 1020M
done

