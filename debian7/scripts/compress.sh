#!/bin/bash

set -x

date

SYSTEMVM_RELEASE=$(date +%-y.%-m.%-d)
DISK_IMAGE=$1

gzip -v ${DISK_IMAGE}-${SYSTEMVM_RELEASE}.qcow2
