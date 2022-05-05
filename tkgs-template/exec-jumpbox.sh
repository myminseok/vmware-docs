if [ -z $1 ]; then
	echo "please set NAMESPACE param";
	echo "$0 namespace cluster-name";
	exit 1;
fi
export NAMESPACE=$1

if [ -z $2 ]; then
	echo "please set clustername";
	echo "$0 namespace cluster-name";
	exit 1;
fi

export CLUSTER=$2

export VMNAME=$(kubectl get virtualmachines -n $1 | grep $CLUSTER |  grep 'control-plane' | head -1 | awk '{print $1}')
export VMIP=$(kubectl -n $NAMESPACE get virtualmachine/$VMNAME -o jsonpath='{.status.vmIp}')
echo "VMNAME:$VMNAME"
echo "VMIP:$VMIP"
if [ -z "$VMIP" ]; then
	echo "no VMIP!";
	exit 1;
fi
kubectl exec -it jumpbox /usr/bin/ssh vmware-system-user@$VMIP
