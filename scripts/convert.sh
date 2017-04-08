#!/bin/bash

set -x

date

SYSTEMVM_RELEASE="17.0.62"
DISK_IMAGE=$1

qemu-img convert -f qcow2 -O vpc ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.qcow2 ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.vhd
