#!/bin/sh

set -x

# Start the magic!
echo "Patching the local filesystem with files from the cdrom!"

# Some variables
CDROM_DEV="/dev/cdrom"
CDROM_MNT="/mnt/cdrom"

PATCH_FILE="cloud-scripts.tgz"
PATCH_FILE_SSVM_CPVM="systemvm.zip"
PATCH_FOLDER=${CDROM_MNT}

SSVM_CPVM_FOLDER="/opt/cosmic/agent"

echo "Checking if cdrom drive exists..."
blkid ${CDROM_DEV}
ret=$?
if [ ${ret} -ne 0 ]; then
    echo "No cdrom found, quit patching!"
    exit 1
fi

echo "Mounting the cdrom"
mkdir -p ${CDROM_MNT}
mount -o ro ${CDROM_DEV} ${CDROM_MNT}

echo "Copying files to / ..."
tar -xvf ${CDROM_MNT}/${PATCH_FILE} -C /

echo "Copying ssvm/cpvm files to ${SSVM_CPVM_FOLDER} ..."
mkdir -p ${SSVM_CPVM_FOLDER}
unzip ${CDROM_MNT}/${PATCH_FILE_SSVM_CPVM} -d ${SSVM_CPVM_FOLDER}
