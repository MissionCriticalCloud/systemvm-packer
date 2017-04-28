#!/bin/bash

set -x

echo "CloudStack 4.4 iptables compatibility"
cp /tmp/iptables-persistent /etc/init.d/iptables-persistent
chmod 755 /etc/init.d/iptables-persistent
cp /tmp/iptables.conf /etc/iptables/iptables.conf
chmod 755 /etc/iptables/iptables.conf
