#!/usr/bin/env bash
#
# Restart the SSH server and firewall with fail2ban enabled on new listening port
#
# Filename: restart-firewall-sshd-fb.sh
#

systemctl restart fail2ban.service
systemctl restart firewalld.service
systemctl restart sshd.service

