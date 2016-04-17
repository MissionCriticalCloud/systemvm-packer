#!/bin/bash

set -x

date

# Remove 5s grub timeout to speed up booting
configure_grub () {
  grep GRUB_TIMEOUT=0 /etc/default/grub && return

  cat <<EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.
GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX='debian-installer=en_US console=tty0 console=ttyS0,19200n8'
GRUB_TERMINAL=serial
GRUB_SERIAL_COMMAND="serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1"
EOF

  update-grub
}

return 2>/dev/null || configure_grub
