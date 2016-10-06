#!/bin/bash

set -x

date
DISK_IMAGE=$1
SYSTEMVM_RELEASE=$(date +%-y.%-m.%-d)

#qemu-img convert -c -f qcow2 -O qcow2 ${DISK_IMAGE} ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.qcow2
qemu-img convert -f qcow2 -O vpc ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.qcow2 ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.vhd
qemu-img convert -f qcow2 -O vmdk -o subformat=streamOptimized ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.qcow2 ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.vmdk

$(dirname $0)/convert-ova.sh ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.vmdk
rm ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.vmdk
