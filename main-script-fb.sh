#!/usr/bin/env bash
#
# This is the main script that runs the entire first-boot configuration
#
# Filename: main-script-fb.sh
#
# Variables: $buildDir 
#
cd $(dirname $0) # Change working directory to $buildDir
source ./custom-variables-fb.var


# Abort the script if it has been executed already
if [ -f $buildDir/.ranonce ]
then
	echo "Exiting main-script-fb.sh.... This script has ran once already. [ $(date) ]"
	logger "Exiting main-script-fb.sh.... This script has ran once already. [ $(date) ]"
	chmod -x $buildDir/main-script-fb.sh
	systemctl disable firstboot-fb.service
	exit 66
fi

echo "+++++++++++ THIS SCRIPT HAS STARTED AT $(date) ++++++++++"
touch $buildDir/.ranonce


scriptfiles="
sysctl-fb.sh
tcpwrapper-fb.sh
firewall-fb.sh
sshd_config_modifier-fb.sh
ssh-selinux-port-fb.sh
fail2ban-fb.sh
restart-firewall-sshd-fb.sh
lvm_cache_trim-fb.sh
rebuilt4next_reboot-fb.sh
ssmtp-fb.sh
ntp_server_setup-fb.sh
dns_server_setup-fb.sh
http_ftp_install-tree-fb.sh
add-hosts-fb.sh
libvirt-prep-fb.sh
vm-kscreator-fb.sh
build-vms-fb.sh
"


# Execute each script in sequential order
for script in $scriptfiles
do
	echo "--- [ $(date) ] ---" >> $buildDir/output/$script.output
	/bin/bash -x $buildDir/$script >>$buildDir/output/$script.output 2>&1

	# abort the main script in case of error
	if [ $? -ne 0 ]
	then
		echo  "ERROR: $script in main-script has failed at $(date)"
		logger -i "ERROR: $script in main-script has failed at $(date)"
		exit 99
	fi
done


# Run only if all above scripts are successful
echo "+++++++++++ THIS SCRIPT HAS COMPLETED SUCCESSFULLY AT $(date) ++++++++++"
chmod -x $buildDir/main-script-fb.sh
systemctl disable firstboot-fb.service
reboot

