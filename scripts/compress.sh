#!/bin/bash

set -x

date

SYSTEMVM_RELEASE=$(date +%-y.%-m.%-d)
DISK_IMAGE=$1

bzip2 ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.qcow2
zip ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.vhd.zip ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.vhd
