#!/bin/bash

set -x

date

SYSTEMVM_RELEASE="17.0.62"
DISK_IMAGE=$1

gzip -v ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.qcow2
gzip -v ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.vhd
