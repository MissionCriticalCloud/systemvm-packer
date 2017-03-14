#!/bin/bash
# 
# http://jbrazile.blogspot.com.es/2012/01/scripted-vmdkova-images-wboxgrinder-and.html
#
set -x
VMDK=$1
NAME=$(basename $VMDK .vmdk)
OS=$2
IMAGE=
SZMB=256
INSTDIR=/tmp/vbox-inst
BUILDDIR=/tmp/vbox-build
MAIN_DIR=$(dirname $(readlink -f $VMDK))

if [ -z "$NAME" ]; then
  echo "Usage: ova-gen.sh <appliance-name> [ostype]"
  exit 1
fi

if [ -z "$OS" ]; then
  OS=Debian_64
  echo Setting OS type to $OS
fi

rm -rf $INSTDIR $BUILDDIR
mkdir -p $BUILDDIR $INSTDIR

for vmdk in `find ${MAIN_DIR} -name '*.vmdk'`; do
  echo Copying $vmdk to $INSTDIR
  cp $vmdk $INSTDIR
  IMAGE="$INSTDIR/`basename $vmdk`"
  echo "IMAGE: $IMAGE"
done

VBoxManage createvm --name ${NAME} --ostype ${OS} --register --basefolder ${INSTDIR}
VBoxManage modifyvm ${NAME} --memory ${SZMB} --vram 32
VBoxManage storagectl ${NAME} --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach ${NAME} --storagectl "SATA Controller" --type hdd --port 0 --device 0 --medium ${IMAGE}
VBoxManage export ${NAME} --manifest -o ${BUILDDIR}/${NAME}.ovf
VBoxManage unregistervm ${NAME} --delete
echo "Your appliance is ready at ${BUILDDIR}/${NAME}.ovf"

$(dirname $0)/convert-vbox-ovf-to-vmware.py ${BUILDDIR}/${NAME}.ovf
cd ${BUILDDIR} && openssl sha1 *.vmdk *.ovf > ${NAME}.mf && tar -cvf ${NAME}.ova ${NAME}*.{ovf,mf,vmdk}
cp ${BUILDDIR}/${NAME}.ova ${MAIN_DIR}
rm -rf $INSTDIR $BUILDDIR
