#!/usr/bin/env bash
#
# Set up HTTP and FTP install trees.
#
# Filename: http_ftp_install-tree-fb.sh
#
# Variables: $osImageURL, $buildDir
#
source ./custom-variables-fb.var

# Get the basename of the image file downloaded (i.e. CentOS-7-x86_64-DVD-1511.iso)
imageFilename=$(basename "$osImageURL")


# Setting up the install trees
mkdir -p /var/www/html/inst/ /var/ftp/pub/inst
wget -qO $buildDir/$imageFilename $osImageURL
modprobe loop
mount -r -o loop -t iso9660 $buildDir/$imageFilename /media
echo /var/www/html/inst /var/ftp/pub/inst | xargs -n 1 cp -a /media/.
semanage fcontext -a -t httpd_sys_content_t "/var/www/html(/.*)?"
semanage fcontext -a -t public_content_t "/var/ftp/pub(/.*)?"
restorecon -R /var/www/html
restorecon -R /var/ftp/pub
systemctl restart httpd.service && systemctl restart vsftpd.service

