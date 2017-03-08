#!/bin/bash

set -x

date

SYSTEMVM_RELEASE=$(cat $(dirname $0)/../files/systemvmtemplate-version)
DISK_IMAGE=$1
TEMP_DIR="/data/templates/temp"

echo "Zero out the free space to save space"
mkdir -p ${TEMP_DIR} 
virt-sparsify ${DISK_IMAGE} ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.qcow2 --compress --tmp ${TEMP_DIR} --check-tmpdir ignore
rm ${DISK_IMAGE}
