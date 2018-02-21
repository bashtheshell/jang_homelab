#!/usr/bin/env bash
#
# This is an optional wrapper script that would rebuild any of the 4
# VMs. You can choose your preferred minor release and one of two
# environment groups ('Minimal Install' and 'Server with GUI'). 
# Change to the local HTTP/FTP install trees would be made. 
#
# NOTE: DON'T FORGET TO MAKE THIS FILE EXECUTABLE IF YOU WANT TO USE IT
#
# If you come across an issue with this script. Please try removing the ISO
# image from the build directory ($buildDir) and run this script again
# without interruption. Otherwise, submit an issue on GitHub.
#
# Filename: rebuild-vms-fb.sh
#
# Variables: $netIP, $buildDir 
#
source ./custom-variables-fb.var

image_file=""
image_size="" #size in bytes

##########################################################
# Customize the variables below to suit your environment #
##########################################################

# Use 'Minimal Install' environment group? Set to 0 for no. Otherwise yes is presumed.
minimal_install=0


# Set the minor release (i.e. 7.0, 7.1, 7.2, 7.3, 7.4). 7.0 is the default if value's not properly set.
minor_release=7.0


# Specify the Web URL location path (i.e. http://172.16.1.250/centos_image/)
# Hint: This location may be in the same path as 'osImageURL' variable	in 'custom-variables-fb.var' file.
image_path="http://172.16.1.250/centos_image/"


# Set the desired VMs you want to rebuild (i.e. server1, tester1, outsider1, clone1)
# Note: Use the following format -  "server1 tester1 outsider1 clone1". 
# Warning: 'clone1' won't be created without specifying 'server1' too.
vmhosts="server1 tester1 outsider1 clone1"


##########################################################


### Assign the appropriate image file name
case $minor_release in
	7.0)
		image_file="CentOS-7.0-1406-x86_64-Everything.iso"
		image_size=7062159360
		;;
	7.1)
		image_file="CentOS-7-x86_64-Everything-1503-01.iso"
		image_size=7591690240
		;;
	7.2)
		image_file="CentOS-7-x86_64-Everything-1511.iso"
		image_size=7769948160
		;;
	7.3)
		image_file="CentOS-7-x86_64-Everything-1611.iso"
		image_size=8280604672
		;;
	7.4)
		image_file="CentOS-7-x86_64-Everything-1708.iso"
		image_size=8694792192
		;;
	*)
		image_file="CentOS-7.0-1406-x86_64-Everything.iso"
		image_size=7062159360
		;;
esac


### Replace image in the install trees if necessary
if [ ! -e $buildDir/$image_file ] || [ $(du -b "$buildDir/$image_file" | cut -f 1) -ne $image_size ]
then
	### Replace the existing Web URL location of the image with a new one
	sed -i "s,^osImageURL=.*,osImageURL=${image_path}${image_file},g" ./custom-variables-fb.var


	### Remove the existing image from the build directory
	rm -f $buildDir/CentOS-7*.iso


	### Remove the existing install tree subdirectories
	rm -rf /var/www/html/inst 
	rm -rf /var/ftp/pub/inst


	### Rebuild the install trees with the new image from above
	bash -x $buildDir/http_ftp_install-tree-fb.sh
fi


### Clear all packages under the '%packages' tag in vm-kstemplate-fb.cfg
sed -i '/^%packages/,/^%end/{/^%packages/!{/^%end/!d}}' $buildDir/vm-kstemplate-fb.cfg


### Modify the 'vm-kstemplate-fb.cfg' to contain approprate packages under '%packages' tag
if [ $minimal_install -ne 0 ]
then
	sed -i '/^%packages/a @core\nkexec-tools\n' $buildDir/vm-kstemplate-fb.cfg
else 
	awk '{ print }
	/%packages/ {
	print "@^graphical-server-environment"
	print "@base"
	print "@core"
	print "@desktop-debugging"
	print "@dial-up"
	print "@fonts"
	print "@gnome-desktop"
	print "@guest-agents"
	print "@guest-desktop-agents"
	print "@input-methods"
	print "@internet-browser"
	print "@multimedia"
	print "@print-client"
	print "@x11"
	print "chrony"
	print "kexec-tools"
	print ""
	}' $buildDir/vm-kstemplate-fb.cfg > $buildDir/vm-kstemplate-fb.cfg.tmp
	mv $buildDir/vm-kstemplate-fb.cfg.tmp $buildDir/vm-kstemplate-fb.cfg
fi


### Recreate the kickstart files for all VMs
bash -x $buildDir/vm-kscreator-fb.sh


### Stop the VMs and remove its configurations
for vm in $vmhosts
do
	vmdomain=""
	
	### Assign the appropriate VM domain name
	case $vm in 
		"server1")
			vmdomain="server1.example.com"
			;;
		"tester1")
			vmdomain="tester1.example.com"
			;;
		"outsider1")
			vmdomain="outsider1.example.org"
			;;
		"clone1")
			vmdomain="clone1.example.org"
			;;
		*)
			echo "ERROR: There exists an invalid host. Exiting script."
			exit
			;;
	esac
	
	virsh destroy $vmdomain
	virsh undefine $vmdomain
	
done


### Rebuid the VMs
sed -i "s/^hosts=.*/hosts=\"${vmhosts}\"/" $buildDir/build-vms-fb.sh
bash -x $buildDir/build-vms-fb.sh

