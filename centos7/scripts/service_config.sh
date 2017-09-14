#!/bin/bash

set -x

date

# Bump the new version every day
SYSTEMVM_RELEASE=$(date +%-y.%-m.%-d)

install_cloud_scripts () {
   echo "Installing initial version of cloud-early-config"
   chmod 755 /etc/init.d/cloud-early-config
   chkconfig --add cloud-early-config
   chkconfig cloud-early-config on

   echo "Installing initial version of patchsystemvm.sh"
   mkdir -p /opt/cloud/bin/
   mv /tmp/patchsystemvm.sh /opt/cloud/bin/
   chmod 755 /opt/cloud/bin/patchsystemvm.sh
}

do_signature () {
  echo 'zero' > /var/cache/cloud/cloud-scripts-signature
  echo "Cloudstack Release $SYSTEMVM_RELEASE $(date)" > /etc/cloudstack-release
}

configure_services () {
  mkdir -p /var/www/html
  mkdir -p /opt/cloud/bin
  mkdir -p /var/cache/cloud
  mkdir -p /usr/share/cloud
  mkdir -p /usr/local/cloud

  # Fix haproxy directory issue
  mkdir -p /var/lib/haproxy

  install_cloud_scripts
  do_signature
}

return 2>/dev/null || configure_services
