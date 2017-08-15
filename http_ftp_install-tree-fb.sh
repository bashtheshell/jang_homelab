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


# Download the image persistently until it is successfully completed
while [ 1 ] 
do
    wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 --tries 20 --continue \
        -qO $buildDir/$imageFilename $osImageURL
    
    # Exit the while loop if successful
    if [ $? = 0 ]
    then
        break
    fi
    sleep 1s;
done


# Mount the downloaded image
modprobe loop
while [ 1 ]
do
    mount -r -o loop -t iso9660 $buildDir/$imageFilename /media
    
    # Exit the while loop if successful
    if [ $? = 0 ]
    then
        break
    fi
    sleep 1s;    
done


# Copy the content of the image to both server directories
mkdir -p /var/www/html/inst/ /var/ftp/pub/inst
cp -a /media/. /var/www/html/inst 
cp -a /media/. /var/ftp/pub/inst


# Set the SELinux file contexts
semanage fcontext -a -t httpd_sys_content_t "/var/www/html(/.*)?"
semanage fcontext -a -t public_content_t "/var/ftp/pub(/.*)?"
restorecon -R /var/www/html
restorecon -R /var/ftp/pub


# Restart both web and ftp servers
systemctl restart httpd.service && systemctl restart vsftpd.service

