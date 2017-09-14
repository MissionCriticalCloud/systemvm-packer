#!/bin/bash

set -x

date

add_backports () {
  sed -i '/backports/d' /etc/apt/sources.list
  echo 'deb http://http.debian.net/debian wheezy-backports main' >> /etc/apt/sources.list
}

apt_upgrade () {
  DEBIAN_FRONTEND=noninteractive
  DEBIAN_PRIORITY=critical

  add_backports

  apt-get clean
  apt-get -q -y --force-yes update
  apt-get -q -y --force-yes upgrade
}

return 2>/dev/null || apt_upgrade
