#!/bin/bash

set -x

grep nf_conntrack_ipv4 /etc/modules-load.d/10-conntrack-modules.conf && return

cat >> /etc/modules-load.d/10-conntrack-modules.conf << EOF
nf_conntrack_ipv4
nf_conntrack
nf_conntrack_ftp
nf_conntrack_pptp
nf_conntrack_proto_gre
nf_nat_tftp
nf_nat_ftp
EOF
