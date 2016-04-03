#!/bin/bash

set -x

date

# Bump the new version every day
SYSTEMVM_RELEASE=$(date +%-y.%-m.%-d)

configure_apache2 () {
   # Enable ssl, rewrite and auth
   a2enmod ssl rewrite auth_basic auth_digest
   a2ensite default-ssl
   # Backup stock apache configuration since we may modify it in Secondary Storage VM
   cp /etc/apache2/sites-available/default /etc/apache2/sites-available/default.orig
   cp /etc/apache2/sites-available/default-ssl /etc/apache2/sites-available/default-ssl.orig
   sed -i 's/SSLProtocol all -SSLv2$/SSLProtocol all -SSLv2 -SSLv3/g' /etc/apache2/mods-available/ssl.conf
}

install_cloud_scripts () {
   echo "Installing initial version of cloud-early-config"
   mv /tmp/cloud-early-config /etc/init.d
   chmod 755 /etc/init.d/cloud-early-config
   chkconfig --add cloud-early-config
   chkconfig cloud-early-config on

   echo "Installing initial version of patchsystemvm.sh"
   mkdir -p /opt/cloud/bin/
   mv /tmp/patchsystemvm.sh /opt/cloud/bin/
   chmod 755 /opt/cloud/bin/patchsystemvm.sh
}

do_signature () {
  mkdir -p /var/cache/cloud/ /usr/share/cloud/
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

  chkconfig xl2tpd off

  # Disable services that slow down boot and are not used anyway
  chkconfig x11-common off
  chkconfig console-setup off

  configure_apache2
}

return 2>/dev/null || configure_services
