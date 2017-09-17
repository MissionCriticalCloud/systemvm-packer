#!/bin/sh

set -x

# Start the magic!
echo "Configuring the private nic!"

CMDLINE="/var/cache/cloud/cmdline"
CMDLINE_DONE="/var/cache/cloud/cmdline_incoming"
SSH_PORT=3922

# Wait for the config to arrive
while [ ! -f ${CMDLINE_DONE} ]
do
  sleep 1
done
cat ${CMDLINE}

DOMAIN=
DNS1=
DNS2=
NEW_HOSTNAME=
PRIVATE_NIC_IPV4=
PRIVATE_NIC_IPv4_NETMASK=
PRIVATE_NIC_MAC=

for i in $(cat ${CMDLINE})
  do
    KEY=$(echo ${i} | cut -d= -f1)
    VALUE=$(echo ${i} | cut -d= -f2)
    case ${KEY} in
      domain)
        DOMAIN=${VALUE}
        ;;
      dns1)
        DNS1=${VALUE}
        ;;
      dns2)
        DNS2=${VALUE}
        ;;
      name)
        NEW_HOSTNAME=${VALUE}
        ;;
      eth0ip)
        PRIVATE_NIC_IPV4=${VALUE}
        ;;
      eth0mask)
        PRIVATE_NIC_IPv4_NETMASK=${VALUE}
        ;;
      eth0mac)
        PRIVATE_NIC_MAC=${VALUE}
        ;;
      *)
        ;;
    esac
done

# Setup private nic
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
IPV6INIT="no"
BOOTPROTO="none"
ONBOOT="yes"
HWADDR="${PRIVATE_NIC_MAC}"
IPADDR="${PRIVATE_NIC_IPV4}"
NETMASK="${PRIVATE_NIC_IPv4_NETMASK}"
EOF

# Setup hostname
hostnamectl set-hostname ${NEW_HOSTNAME}

# Setup dns
cat > /etc/resolv.conf << EOF
search ${DOMAIN}
`if [ ! -z "${DNS1}" ]; then echo "nameserver ${DNS1}"; fi`
`if [ ! -z "${DNS2}" ]; then echo "nameserver ${DNS2}"; fi`
EOF

# Reload the private nic
ifdown eth0; ifup eth0

# Configure SSH
cat > /etc/resolv.conf << EOF
Port ${SSH_PORT}
AddressFamily inet
ListenAddress ${PRIVATE_NIC_IPV4}

PermitRootLogin yes
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

SyslogFacility AUTHPRIV

ChallengeResponseAuthentication no

PrintMotd yes

AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
AcceptEnv XMODIFIERS
EOF

# Restart the SSH daemon
systemctl restart sshd