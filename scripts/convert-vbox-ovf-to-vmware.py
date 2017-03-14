#!/usr/bin/env python
#
# usage:
#        conv2vmx-ovf.py some-vm.ovf
#
# ref: http://www.cnblogs.com/eshizhan/p/3332020.html
#

import sys
import os
fn = sys.argv[1]
fp = open(fn).read()
if hasattr(fp,'decode'): 
    fp = fp.decode('utf-8')

fp = fp.replace('<OperatingSystemSection ovf:id="80">', '<OperatingSystemSection ovf:id="101">')

fp = fp.replace('<vssd:VirtualSystemType>virtualbox-2.2', '<vssd:VirtualSystemType>vmx-7')

fp = fp.replace('<rasd:Caption>sataController', '<rasd:Caption>scsiController')
fp = fp.replace('<rasd:Description>SATA Controller', '<rasd:Description>SCSI Controller')
fp = fp.replace('<rasd:ElementName>sataController', '<rasd:ElementName>scsiController')
fp = fp.replace('<rasd:ResourceSubType>AHCI', '<rasd:ResourceSubType>lsilogic')
fp = fp.replace('<rasd:ResourceType>20', '<rasd:ResourceType>6')

end = fp.find('<rasd:Caption>sound')
start = fp.rfind('<Item>', 0, end)
fp = fp[:start] + '<Item ovf:required="false">' + fp[start+len('<Item>'):]

nfp = open(fn + '.vmx', 'wb')
nfp.write(fp.encode('utf8'))
nfp.close()
os.rename(fn + '.vmx', fn)
