



## SSH into vCenter to get credentials for the supervisor cluster master VMs

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

## SSH to the supervisor cluster control plane node IP address noted 

```
export SV_MASTER_IP=10.213.227.45
export SV_MASTER_PASSWORD=xxxNLlY=

sshpass -p "$SV_MASTER_PASSWORD" ssh  -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@"$SV_MASTER_IP"
```


## SCP to the supervisor cluster control plane node IP address noted 

```
export SV_MASTER_IP=10.213.227.45
export SV_MASTER_PASSWORD=xxxNLlY=

sshpass -p "$SV_MASTER_PASSWORD" scp  -r FOLDER   root@$SV_MASTER_IP:~/

```




## Get SSH secrets of TKC

```

kubectl vsphere login --server WCP-URL -u administrator@vsphere.local --insecure-skip-tls-verify 

kubectl config use-context VSPHERE-NAMESPACE


kubectl get secret -n ns1 | grep ssh
ns1-tkg1-ssh                    kubernetes.io/ssh-auth                1      2d1h
ns1-tkg1-ssh-password           Opaque                                1      2d1h
ns1-tkg2-ssh                    kubernetes.io/ssh-auth                1      2d2h
ns1-tkg2-ssh-password           Opaque                                1      2d2h


kubectl get secret -n ns1 ns1-tkg1-ssh -o jsonpath='{.data.ssh-privatekey}' | base64 -d > ns1-tkg1-ssh.key

kubectl get secret -n ns1 ns1-tkg1-kubeconfig -o jsonpath='{.data.value}' | base64 -d > ns1-tkg1-kubeconfig

kubectl get secret ns1-tkg1-ssh-password  -o jsonpath='{.data.ssh-passwordkey}' | base64 -d 


kubectl get nodes -o wide --kubeconfig=./ns1-tkg1-kubeconfig
NAME                                      STATUS   ROLES    AGE    VERSION             INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                 KERNEL-VERSION       CONTAINER-RUNTIME
ns1-tkg1-control-plane-wwhfp              Ready    master   7d7h   v1.18.10+vmware.1   10.244.1.66   <none>        VMware Photon OS/Linux   4.19.154-3.ph3-esx   containerd://1.3.4
ns1-tkg1-workers-6r4l6-569ff87f5b-fjlpx   Ready    <none>   7d7h   v1.18.10+vmware.1   10.244.1.67   <none>        VMware Photon OS/Linux   4.19.154-3.ph3-esx   containerd://1.3.4
ns1-tkg1-workers-6r4l6-569ff87f5b-j4g8z   Ready    <none>   7d7h   v1.18.10+vmware.1   10.244.1.69   <none>        VMware Photon OS/Linux   4.19.154-3.ph3-esx   containerd://1.3.4
ns1-tkg1-workers-6r4l6-569ff87f5b-qppmt   Ready    <none>   7d7h   v1.18.10+vmware.1   10.244.1.68   <none>        VMware Photon OS/Linux   4.19.154-3.ph3-esx   containerd://1.3.4


# test.
ssh -i ns1-tkg1-ssh.key  vmware-system-user@10.244.1.66


```



