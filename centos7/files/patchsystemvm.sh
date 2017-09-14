#!/bin/bash

set -x
logfile="/var/log/patchsystemvm.log"
# To use existing console proxy .zip-based package file
patch_console_proxy() {
   local patchfile=$1
   rm /usr/local/cloud/systemvm -rf
   mkdir -p /usr/local/cloud/systemvm
   echo "All" | unzip $patchfile -d /usr/local/cloud/systemvm >$logfile 2>&1
   find /usr/local/cloud/systemvm/ -name \*.sh | xargs chmod 555
   return 0
}

consoleproxy_svcs() {
   systemctl enable cloud
   systemctl enable postinit
   systemctl disable cloud-passwd-srvr
   systemctl disable haproxy
   systemctl disable dnsmasq
   systemctl enable ssh
   systemctl disable apache2
   systemctl disable nfs-common
   systemctl disable portmap
   systemctl disable keepalived
   systemctl disable conntrackd
   echo "cloud postinit ssh" > /var/cache/cloud/enabled_svcs
   echo "cloud-passwd-srvr haproxy dnsmasq apache2 nfs-common portmap" > /var/cache/cloud/disabled_svcs
   mkdir -p /var/log/cloud
}

secstorage_svcs() {
   systemctl enable cloud
   systemctl enable postinit
   systemctl disable cloud-passwd-srvr
   systemctl disable haproxy
   systemctl disable dnsmasq
   systemctl enable portmap
   systemctl enable nfs-common
   systemctl enable ssh
   systemctl disable apache2
   systemctl disable keepalived
   systemctl disable conntrackd
   echo "cloud postinit ssh nfs-common portmap" > /var/cache/cloud/enabled_svcs
   echo "cloud-passwd-srvr haproxy dnsmasq" > /var/cache/cloud/disabled_svcs
   mkdir -p /var/log/cloud
}

routing_svcs() {
   grep "redundant_router=1" /var/cache/cloud/cmdline > /dev/null
   RROUTER=$?
   systemctl disable cloud
   systemctl enable haproxy
   systemctl enable ssh
   systemctl disable nfs-common
   systemctl disable portmap
   echo "ssh haproxy apache2" > /var/cache/cloud/enabled_svcs
   echo "cloud nfs-common portmap" > /var/cache/cloud/disabled_svcs
   if [ $RROUTER -eq 0 ]
   then
       systemctl disable dnsmasq
       systemctl disable cloud-passwd-srvr
       systemctl enable keepalived
       systemctl enable conntrackd
       systemctl enable postinit
       echo "keepalived conntrackd postinit" >> /var/cache/cloud/enabled_svcs
       echo "dnsmasq cloud-passwd-srvr" >> /var/cache/cloud/disabled_svcs
   else
       systemctl enable dnsmasq
       systemctl enable cloud-passwd-srvr
       systemctl disable keepalived
       systemctl disable conntrackd
       echo "dnsmasq cloud-passwd-srvr " >> /var/cache/cloud/enabled_svcs
       echo "keepalived conntrackd " >> /var/cache/cloud/disabled_svcs
   fi
}

CMDLINE=$(cat /var/cache/cloud/cmdline)
TYPE="router"
PATCH_MOUNT=$1
Hypervisor=$2

for i in $CMDLINE
  do
    # search for foo=bar pattern and cut out foo
    KEY=$(echo $i | cut -d= -f1)
    VALUE=$(echo $i | cut -d= -f2)
    case $KEY in
      type)
        TYPE=$VALUE
        ;;
      *)
        ;;
    esac
done

if [ "$TYPE" == "consoleproxy" ] || [ "$TYPE" == "secstorage" ]  && [ -f ${PATCH_MOUNT}/systemvm.zip ]
then
  patch_console_proxy ${PATCH_MOUNT}/systemvm.zip
  if [ $? -gt 0 ]
  then
    printf "Failed to apply patch systemvm\n" >$logfile
    exit 5
  fi
fi


#empty known hosts
echo "" > /root/.ssh/known_hosts

if [ "$TYPE" == "router" ] || [ "$TYPE" == "vpcrouter" ]
then
  routing_svcs
  if [ $? -gt 0 ]
  then
    printf "Failed to execute routing_svcs\n" >$logfile
    exit 6
  fi
fi

if [ "$TYPE" == "consoleproxy" ]
then
  consoleproxy_svcs
  if [ $? -gt 0 ]
  then
    printf "Failed to execute consoleproxy_svcs\n" >$logfile
    exit 7
  fi
fi

if [ "$TYPE" == "secstorage" ]
then
  secstorage_svcs
  if [ $? -gt 0 ]
  then
    printf "Failed to execute secstorage_svcs\n" >$logfile
    exit 8
  fi
fi

exit $?

