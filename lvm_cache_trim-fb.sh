#!/usr/bin/env bash
#
# This script configures LVM cache and TRIM
#
# Filename: lvm_cache_trim-fb.sh
#
# Variables: $ssdDrive, $volGroupName
#
source ./custom-variables-fb.var

# Configure /dev/sdc (solid state drive) for LVM cache
sgdisk -Z $ssdDrive
sgdisk -n 1:0:+20G -t 1:8e00 -c 1:"host LVM cache" $ssdDrive
partprobe $ssdDrive


# Set up LVM
pvcreate "$ssdDrive"1
vgextend $volGroupName "$ssdDrive"1
lvcreate -n "$volGroupName"cache -L19.9G $volGroupName "$ssdDrive"1
lvcreate -n "$volGroupName"cacheMeta -L20M $volGroupName "$ssdDrive"1
lvconvert -y --type cache-pool --poolmetadata "$volGroupName"/"$volGroupName"cacheMeta "$volGroupName"/"$volGroupName"cache
lvconvert -y --type cache --cachepool "$volGroupName"/"$volGroupName"cache "$volGroupName"/root


# Set up TRIM for LVM
sed -i 's/issue_discards = 0/issue_discards = 1/g' /etc/lvm/lvm.conf


# Enable TRIM at boot
systemctl enable fstrim.timer

