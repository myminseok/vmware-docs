



# SSH into vCenter to get credentials for the supervisor cluster master VMs

```
export VC_ROOT_PASSWORD=
export VC_IP=


sshpass -p "${VC_ROOT_PASSWORD}" ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no -q root@"${VC_IP}" com.vmware.shell /usr/lib/vmware-wcp/decryptK8Pwd.py


Shell access is granted to root
Read key from file

Connected to PSQL

Cluster: domain-c8:51d7f486-53c2-43a3-9a49-15a9f47d0f4b
IP: 10.213.227.45
PWD: xxxNLlY=
------------------------------------------------------------
```

# SSH to the supervisor cluster control plane node IP address noted 

```
export SV_MASTER_IP=10.213.227.45
export SV_MASTER_PASSWORD=xxxNLlY=

sshpass -p "$SV_MASTER_PASSWORD" ssh  -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@"$SV_MASTER_IP"
```


# SCP to the supervisor cluster control plane node IP address noted 

```
export SV_MASTER_IP=10.213.227.45
export SV_MASTER_PASSWORD=xxxNLlY=

sshpass -p "$SV_MASTER_PASSWORD" scp  -r FOLDER   root@$SV_MASTER_IP:~/

```
