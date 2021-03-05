#!/bin/bash
set +x

if [ -z $1 ] || [ -z $2 ] ; then
	echo "${BASH_SOURCE[0]} VC_IP VC_ADMIN_USER  VC_ADMIN_PASSWORD"
	exit
fi

VC_IP="$1" # pacific-vcsa.haas-455.pez.vmware.com
VC_ADMIN_USER="$2" # administrator@vsphere.local'
VC_ADMIN_PASSWORD="$3" #Password for VCenter user


sshpass -p "${VC_ADMIN_PASSWORD}" ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no -q root@"${VC_IP}" com.vmware.shell /usr/lib/vmware-wcp/decryptK8Pwd.py > tmp_sv_secret.txt

eval $(grep IP ./tmp_sv_secret.txt | awk '{print "export SV_MASTER_IP="$2}')
eval $(grep PWD ./tmp_sv_secret.txt | awk '{print "export SV_MASTER_PASSWORD="$2}')

echo "SV_MASTER_IP=$SV_MASTER_IP"
echo "SV_MASTER_PASSWORD=$SV_MASTER_PASSWORD"
rm -rf ./tmp_sv_secret.txt

sshpass -p "$SV_MASTER_PASSWORD" ssh  -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@"$SV_MASTER_IP"
