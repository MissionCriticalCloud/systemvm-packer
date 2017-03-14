#!/bin/bash

output_dir=$1
name=$2
channel=$3
iteration=$4

EXTS="qcow2.bz2 ova vhd.zip"

for ext in $EXTS ; do
    scp ${output_dir}/${name}.${ext} incoming@images.qstack.com:/srv/repos/images/${channel}/systemvm/${name}-${iteration}.${ext}
    ssh incoming@images.qstack.com ln -sfn /srv/repos/images/${channel}/systemvm/${name}-${iteration}.${ext} /srv/repos/images/${channel}/systemvm/${name}.${ext}
done