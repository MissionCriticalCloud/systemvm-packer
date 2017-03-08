#!/bin/bash

set -x

date

SYSTEMVM_RELEASE=$(cat $(dirname $0)/../files/systemvmtemplate-version)
DISK_IMAGE=$1

bzip2 ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.qcow2
zip ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.vhd.zip ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.vhd
