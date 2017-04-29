#!/usr/bin/env bash
#
# Use template to uniquely create kickstart file for each VM host
#
# Filename: vm-kscreator-fb.sh
#
# Variables: $buildDir, $netIP, $rootPass, $acctUserName, $acctUserPass, $acctUserGECOS
#
source ./custom-variables-fb.var

# List of hosts
hosts="server1 tester1 outsider1 clone1"

# Kickstart template file
kickstarter=$buildDir/vm-kstemplate-fb.cfg


# Inject the public key created in post-install script
sed -i "s,SSHKEY,$(cat /root/.ssh/id_rsa.pub),g" $kickstarter

# Replace NETIP with IP address of physical host
sed -i "s/NETIP/$netIP/g" $kickstarter

# Replace ROOTPASS with actual system root password
sed -i "s,ROOTPASS,$rootPass,g" $kickstarter

# Replace ACCTUSERNAME with the username on the system
sed -i "s/ACCTUSERNAME/$acctUserName/g" $kickstarter

# Replace ACCTUSERPASS with the user's password
sed -i "s,ACCTUSERPASS,$acctUserPass,g" $kickstarter

# Replace ACCTUSERGECOS with the user's GECOS (usually their full name)
sed -i "s/ACCTUSERGECOS/$acctUserGECOS/g" $kickstarter



# Create kickstart file for each host with correct information and set 600 permission on file
for server in $hosts
do
	if [ $server = "outsider1" ] || [ $server = "clone1" ]
	then
		sed "s/SERVERHOST/$server/g" \
		$kickstarter | 
		sed "s/--hostname=$server.example.com/--hostname=$server.example.org/g" > \
$buildDir/"$server"-ks.cfg
	else
		sed "s/SERVERHOST/$server/g" $kickstarter > $buildDir/"$server"-ks.cfg
	fi
	chmod 600 $buildDir/"$server"-ks.cfg
done

