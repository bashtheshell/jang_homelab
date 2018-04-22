#!/usr/bin/env bash
#
# This script creates 4 VMs. The first three will be created
# from scratch and the last one will be cloned from the first VM.
#
# Filename: build-vms-fb.sh
#
# Variables: $netIP, $buildDir 
#
source ./custom-variables-fb.var


# List of hosts
hosts="server1 tester1 outsider1 clone1"


# server1.example.com
# 00:11:22:33:44:01
# 00:11:22:33:44:02

# tester1.example.com
# 00:11:22:33:44:11
# 00:11:22:33:44:12

# outsider1.example.org
# 00:11:22:33:44:21
# 00:11:22:33:44:22

# clone1.example.org
# 00:11:22:33:44:31
# 00:11:22:33:44:32


# Create the first 3 VMs
for server in $hosts
do
	domain=""
	mac=""
	mac2=""
	network=""

	case $server in
		"server1")
			domain="example.com"
			mac="00:11:22:33:44:01"
			mac2="00:11:22:33:44:02"
			network="default"
			;;
			
		"tester1")
			domain="example.com"
			mac="00:11:22:33:44:11"
			mac2="00:11:22:33:44:12"
			network="default"
			;;
			
		"outsider1")
			domain="example.org"
			mac="00:11:22:33:44:21"
			mac2="00:11:22:33:44:22"
			network="outsider"
			;;
			
		"clone1")
			# Skip to the next interation as 'virt-install' for clone1 is not needed
			continue
			;;

		*)
			echo "ERROR: There appears to be an issue with the virt-install script."
			exit 64
	esac

	virt-install \
	--name $server.$domain \
	--location ftp://${netIP}/pub/inst \
	--os-type=linux \
	--os-variant centos7.0 \
	--memory 1344 \
	--graphics none \
	--network network=$network,model=virtio,mac=$mac \
	--network network=$network,model=virtio,mac=$mac2 \
	--disk device=disk,path=/dev/$server/hdd1,bus=scsi,cache=none,discard=unmap,format=raw \
	--disk device=disk,path=/dev/$server/hdd2,bus=scsi,cache=none,discard=unmap,format=raw \
	--disk device=disk,path=/dev/$server/hdd3,bus=scsi,cache=none,discard=unmap,format=raw \
	--controller scsi,model=virtio-scsi \
	--initrd-inject "${buildDir}/${server}-ks.cfg" \
	--extra-args "inst.ks=file:/${server}-ks.cfg console=tty0 console=ttyS0" \
	--noautoconsole \
	--noreboot
	
	# Wait for domain to complete install and shutdown before next domain install
	# This is required for virt-clone to work successfully later
	sleep 1
	while [ "$(virsh domstate $server.$domain)" == "running" ]
	do
		echo $server.$domain at $(date "+%m/%d/%y %H:%M:%S")
		sleep 5
	done
	
done

### Clone the fourth VM from the first VM
### This only work if 'server1' was built in this script as well.
if [[ "$hosts" == *server1* && "$hosts" == *clone1* ]]
then
	# Copy the server1 XML config file
	touch $buildDir/original.xml
	chcon -t virt_etc_rw_t $buildDir/original.xml
	virsh dumpxml server1.example.com > $buildDir/original.xml


	# Delete the channel tags in copied file
	sed -i '/<channel/,/<\/channel>$/d' $buildDir/original.xml


	# Build VM using copied file
	virt-clone \
	--original-xml $buildDir/original.xml \
	--name clone1.example.org \
	--check path_exists=off \
	--file /dev/clone1/hdd1 \
	--file /dev/clone1/hdd2 \
	--file /dev/clone1/hdd3 \
	--mac 00:11:22:33:44:31 \
	--mac 00:11:22:33:44:32


	# Delete original file
	rm -f $buildDir/original.xml

	# Remove two bad interfaces
	for i in 00:11:22:33:44:31 00:11:22:33:44:32
	do
		# Get the XML of bad interface on clone1
		touch $buildDir/bad-interface.xml
		chcon -t virt_etc_rw_t $buildDir/bad-interface.xml
		virsh dumpxml clone1.example.org | grep -A4 -B1 -m1 ${i} > $buildDir/bad-interface.xml


		# Remove interface to avoid duplicate
		virsh detach-device clone1.example.org $buildDir/bad-interface.xml --persistent
		rm -f $buildDir/bad-interface.xml


		# Replace new interface
		virsh attach-interface clone1.example.org \
		--type network \
		--source outsider \
		--mac ${i} \
		--model 'virtio' \
		--persistent
	done


	# Gut out the old configs from cloned system
	virt-sysprep \
	--operations defaults,-ssh-userdir \
	--firstboot-command 'vgrename server1VG1 clone1VG1' \
	--firstboot-command "sed -i.backup 's/server1VG1/clone1VG1/g' /etc/fstab" \
	--firstboot-command "sed -i.backup 's/server1VG1/clone1VG1/g' /boot/grub2/grub.cfg" \
	--firstboot-command 'nmcli connection modify eth0 802-3-ethernet.mac-address 00:11:22:33:44:31' \
	--firstboot-command 'nmcli connection modify eth1 802-3-ethernet.mac-address 00:11:22:33:44:32' \
	--hostname clone1.example.org \
	--domain clone1.example.org


elif [[ "$hosts" == *clone1* ]]
then
	echo "WARNING: 'server1' was not built in the script. Therefore 'clone1' won't be built."
fi


# Copy the qemu script to enable VMs to communicate with each other
# UNCOMMENT THE LINES BELOW IF YOU ARE USING VIRTUAL NETWORKS WITH 'NAT' MODE
#
# mkdir /etc/libvirt/hooks
# cp $buildDir/qemu-hooks-fb.sh /etc/libvirt/hooks/qemu
# chmod +x /etc/libvirt/hooks/qemu

