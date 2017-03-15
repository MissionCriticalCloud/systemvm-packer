#!/bin/bash

set -x

cp /tmp/ipsec.conf /etc/
cp /tmp/ipsec.secrets /etc/
cp /tmp/l2tp.conf /etc/ipsec.d/
