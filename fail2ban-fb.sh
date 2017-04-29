#!/usr/bin/env bash
#
# Add fail2ban rule for SSH server
#
# Filename: fail2ban-fb.sh
#

echo -e "[sshd]\nenabled = true\nmaxretry = 4" >> /etc/fail2ban/jail.local

