#!/bin/bash

set -x

date

configure_resolv_conf () {
  grep 8.8.8.8 /etc/resolv.conf && grep 8.8.4.4 /etc/resolv.conf && return

  cat > /etc/resolv.conf << EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
}

# Delete entry in /etc/hosts derived from dhcp
delete_dhcp_ip () {
  result=$(grep 127.0.1.1 /etc/hosts || true)
  [ "${result}" == "" ] && return

  sed -i '/127.0.1.1/d' /etc/hosts
}

configure_networking () {
  configure_resolv_conf
  delete_dhcp_ip
}

return 2>/dev/null || configure_networking
