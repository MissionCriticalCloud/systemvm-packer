#!/bin/bash 

set -x

date

build_time () {
    BUILDTIMEFILE=/etc/cloudstack/buildtime
    echo "Setting build time to ${BUILDTIMEFILE}"
    mkdir -p /etc/cloudstack
    date > ${BUILDTIMEFILE}
}

return 2>/dev/null || build_time
