#!/usr/bin/env bash
#
# This script attempts to modify the 'physicalhost-ks.cfg' file using the
# 'custom-variables-fb.var' file, substituting all the capitalized
# keywords in the kickstart file.
#
# Filename: kickstart-modifier.sh
#
cd $(dirname $0) # change to the directory where this script is located in for below files to work properly

source ./custom-variables-fb.var

kickstartFile=./physicalhost-ks.cfg

### Following keywords will be substitued with value assigned in the sourced file. 
# INSTALLTREEURL
# ROOTPASS
# NETDEVICE
# NETGATEWAY
# NETIP
# NETNAMESERVER
# NETSUBNETMASK
# NETFQDN
# ACCTUSERNAME
# ACCTUSERPASS
# ACCTUSERGECOS
# ONLYUSEDISK
# BOOTLOADERDISK
# VOLGROUPNAME
# SSDDRIVE
# BITBUCKETPRIVATEKEY
# BUILDDIR
# BITBUCKETREPO

sed -i "s,INSTALLTREEURL,$INSTALLTREEURL,g" $kickstartFile
sed -i "s,ROOTPASS,$ROOTPASS,g" $kickstartFile
sed -i "s/NETDEVICE/$NETDEVICE/g" $kickstartFile
sed -i "s/NETGATEWAY/$NETGATEWAY/g" $kickstartFile
sed -i "s/NETIP/$NETIP/g" $kickstartFile
sed -i "s/NETNAMESERVER/$NETNAMESERVER/g" $kickstartFile
sed -i "s/NETSUBNETMASK/$NETSUBNETMASK/g" $kickstartFile
sed -i "s/NETFQDN/$NETFQDN/g" $kickstartFile
sed -i "s/ACCTUSERNAME/$ACCTUSERNAME/g" $kickstartFile
sed -i "s,ACCTUSERPASS,$ACCTUSERPASS,g" $kickstartFile
sed -i "s/ACCTUSERGECOS/$ACCTUSERGECOS/g" $kickstartFile
sed -i "s/ONLYUSEDISK/$ONLYUSEDISK/g" $kickstartFile
sed -i "s/BOOTLOADERDISK/$BOOTLOADERDISK/g" $kickstartFile
sed -i "s/VOLGROUPNAME/$VOLGROUPNAME/g" $kickstartFile
sed -i "s,SSDDRIVE,$SSDDRIVE,g" $kickstartFile
sed -i "s,BITBUCKETPRIVATEKEY,$BITBUCKETPRIVATEKEY,g" $kickstartFile
sed -i "s,BUILDDIR,$BUILDDIR,g" $kickstartFile
sed -i "s,BITBUCKETREPO,$BITBUCKETREPO,g" $kickstartFile
