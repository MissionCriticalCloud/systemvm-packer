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
part / --size=1024 --grow --fstype ext4 --asprimary
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
ethtool
file
ftp
gawk
grep
gzip
iproute
iptables
ipvsadm
java
less
logrotate
lsof
net-tools
ntp
openssh-server
openssl
ppp
psmisc
python
python-flask
python-netaddr
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
yum --enablerepo=epel -y install ipsec-tools xl2tpd httping

# Install pip
curl "https://bootstrap.pypa.io/get-pip.py" | python

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

# Grub tuning -> enable tty console
grubby --update-kernel=ALL --args="crashkernel=0@0 video=1024x768 console=ttyS0,115200n8 console=tty0 consoleblank=0"
grubby --update-kernel=ALL --remove-args="quiet rhgb"

%end
