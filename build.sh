#!/bin/bash

set -x

SYSTEMVM_RELEASE=`date +%-y.%-m.%-d`
DISK_IMAGE=cosmic-systemvm

echo "Removing previous artifacts"
rm -rf ./packer_output
echo "Running Packer"
packer build template.json

cd ./packer_output
mv ${DISK_IMAGE} ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.qcow2
gzip -v ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.qcow2
