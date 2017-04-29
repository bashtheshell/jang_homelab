#!/usr/bin/env bash
#
# Ensure the system is bootable at next boot after making critical boot changes
#
# Filename: rebuilt4next_reboot-fb.sh
#

# Reconfigure grub.conf (able to boot windows after adding ntfs-3g package)
grub2-mkconfig -o /boot/grub2/grub.conf


# Rebuilt initial RAM disk (for LVM TRIM)
dracut --regenerate-all --force