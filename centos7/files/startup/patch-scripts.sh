#!/bin/sh

set -x

# Start the magic!
echo "Patching the local filesystem with files from the cdrom!"

# Some variables
CDROM_DEV="/dev/cdrom"
CDROM_MNT="/mnt/cdrom"

PATCH_FILE="cloud-scripts.tgz"
PATCH_FILE_SSVM_CPVM="systemvm.zip"
PATCH_SHA512_PATH="/opt/cosmic/patch"
PATCH_SHA512_FILE="${PATCH_FILE}.sha512"

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

echo "Generating SHA512 of the patched scripts"
mkdir -p ${PATCH_SHA512_PATH}
sha512sum ${CDROM_MNT}/${PATCH_FILE} | cut -d " " -f 1 > ${PATCH_SHA512_PATH}/${PATCH_SHA512_FILE}
