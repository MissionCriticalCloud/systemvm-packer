skipx
install
text
reboot
lang en_US.UTF-8
keyboard us
timezone --utc GMT

################
# REPOSITORIES #
################
repo --name=os --mirrorlist http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
repo --name=updates --mirrorlist http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates&infra=$infra
repo --name=extras --mirrorlist http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras&infra=$infra
url --mirrorlist http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
eula --agreed

######################
# FIREWALL / SELINUX #
######################
firewall --disabled
selinux --permissive

#################
# ROOT PASSWORD #
#################
rootpw password
authconfig --enableshadow --passalgo=sha512

########
# DHCP #
########
network --onboot yes --device=eth0 --bootproto=dhcp

#############
# PARTITION #
#############
zerombr
clearpart --initlabel --all
part /boot --fstype ext4 --size=500
part pv.cosmic --size=1024 --grow
volgroup vg.cosmic pv.cosmic
logvol / --vgname=vg.cosmic --fstype=ext4 --size=5120 --name=lv_root
logvol /var/log --vgname=vg.cosmic --fstype=ext4 --size=2048 --name=lv_var
bootloader --location=mbr --driveorder=vda --append="console=ttyS0,115200"

############
# PACKAGES #
############
%packages
-*-firmware
-NetworkManager
-b43-openfwwf
-biosdevname
-firewalld
-fprintd
-fprintd-pam
-gtk2
-iprutils
-kbd
-libfprint
-mcelog
-redhat-support-tool
-system-config-*
-wireless-tools

acpid
bind-utils
bzip2
conntrack-tools
curl
diffutils
dnsmasq
dnsmasq-utils
e2fsprogs
epel-release
ethtool
file
ftp
gawk
grep
gzip
haproxy
httpd-tools
iproute
ipset
iptables
iptables-services
ipvsadm
java
keepalived
less
libselinux-python
logrotate
lsof
net-tools
nfs-utils
ntp
openssh-server
openssl
ppp
psmisc
python
python-flask
python-netaddr
python-netifaces
qemu-img
radvd
rpcbind
rsync
rsyslog
samba-common
sed
sharutils
socat
sysstat
tar
tcpdump
tdb-tools
telnet
traceroute
unzip
uuid
vim-enhanced
virt-what
watchdog
wget
zip
%end

############
# SERVICES #
############
services --enabled=network,acpid,ntpd,sshd,tuned --disabled=kdump

######################
# POST INSTALL SHELL #
######################
%post --erroronfail

# Ensure all packages are up to date
yum -y update
yum -y clean all

# Remove some packages
yum -C -y remove authconfig NetworkManager linux-firmware --setopt="clean_requirements_on_remove=1"

# Install epel packages
yum --enablerepo=epel -y install iftop iperf ipsec-tools xl2tpd httping strongswan nginx htop bash-completion bash-completion-extras

yum -y install https://centos7.iuscommunity.org/ius-release.rpm
yum -y install python36u

# Install pip
curl "https://bootstrap.pypa.io/get-pip.py" | python3.6

# Set virtual-guest as default profile for tuned
echo "virtual-guest" > /etc/tune-profiles/active-profile

# Remove existing SSH keys - if generated - as they need to be unique
rm -rf /etc/ssh/*key*

# the MAC address will change
sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-eth0

# We allow the qemu guest agent to do all actions
sed -i '/BLACKLIST_RPC/d' /etc/sysconfig/qemu-ga

# remove logs and temp files
yum -y clean all
rm -f /var/lib/random-seed

# Remove keepalived sample config
rm -f /etc/keepalived/keepalived.conf

# Grub tuning -> enable tty console
grubby --update-kernel=ALL --args="crashkernel=0@0 video=1024x768 console=ttyS0,115200n8 console=tty0 consoleblank=0"
grubby --update-kernel=ALL --remove-args="quiet rhgb"

# disable kdump / postfix
systemctl disable kdump.service
systemctl disable postfix.service

# Sync time via hypervisor
sed -i -e ':a;N;$!ba;s/Use public servers.*iburst/Use hypervisor ntp service\nserver 169.254.0.1 iburst/' /etc/chrony.conf

# enable logrotate compression
sed -i -e 's/^create/create\ncompress/' /etc/logrotate.conf

# Logrotate daily and keep 10 days
sed -i -e 's/weekly/daily/' /etc/logrotate.conf
sed -i -e 's/rotate 4/rotate 10/' /etc/logrotate.conf

# Disable zeroconfig
echo "NOZEROCONF=\"yes\"" > /etc/sysconfig/network

%end
