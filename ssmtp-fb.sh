#!/usr/bin/env bash
#
# Set up ssmtp for public IP address change notification
#
# Filename: ssmtp-fb.sh
#
# Variables: $bitbucketRepo, $emailAddress
#
source ./custom-variables-fb.var


# Use sendmail instead of postfix
alternatives --set mta /usr/sbin/sendmail.ssmtp


# Create a non-privileged cron user responsible for sending notification upon address change
useradd -c "Public IP Address" -m -r -s /sbin/nologin publicip
passwd -l publicip


# Setting up cron job and store current IP address
echo -e "# Check the public IP every hour to see if it has changed\n0 */1 * * * ~/check_ip.sh" > /home/publicip/cronjob.txt
crontab -u publicip /home/publicip/cronjob.txt
curl -4s http://www.icanhazip.com > /home/publicip/current_public_ip.txt


# Download the 'check_ip.sh' script to publicip's home directory
cd /home/publicip/
eval "$(/usr/bin/ssh-agent)"
ssh-add /root/.ssh/id_rsa_bitbucket
if [ ! "$(grep ^bitbucket.org ~/.ssh/known_hosts)" ]
then
        ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts
fi
git init
git fetch privategit:$bitbucketRepo
git checkout FETCH_HEAD 'check_ip.sh'
chown publicip:publicip /home/publicip/*
chmod +x /home/publicip/check_ip.sh
rm -rf .git
ssh-agent -k


# Update email address in 'check_ip.sh' 
sed -i "s/YOUREMAILADDRESS/$emailAddress/g" /home/publicip/check_ip.sh


# Return to previous working directory
cd $buildDir

