
login to supervisor-cluster
```
kubectl vsphere login --insecure-skip-tls-verify --server wcp.haas-455.pez.vmware.com -u user1@vsphere.local

kubectl config get-contexts
CURRENT   NAME                          CLUSTER                       AUTHINFO                                              NAMESPACE
          ns1                           10.213.227.65                 wcp:10.213.227.65:user1@vsphere.local                 ns1
          ns2                           10.213.227.65                 wcp:10.213.227.65:user1@vsphere.local                 ns2
*         wcp.haas-455.pez.vmware.com   wcp.haas-455.pez.vmware.com   wcp:wcp.haas-455.pez.vmware.com:user1@vsphere.local
```

extract your kubeconfig from secret.
```
kubectl get secret -n ns1 | grep kubeconfig
ns1-tkg1-kubeconfig             Opaque                                1      7d7h
ns1-tkg2-kubeconfig             Opaque                                1      14d

kubectl get secret -n ns1 ns1-tkg1-kubeconfig -o jsonpath='{.data.value}' | base64 -d > ns1-tkg1-kubeconfig

kubectl get secret -n ns1 ns1-tkg2-kubeconfig -o jsonpath='{.data.value}' | base64 -d > ns1-tkg2-kubeconfig

```
access TKC by switching the kubeconfig. for example
```
ubuntu@ubuntu-455:~/workspace$ kubectl get nodes --kubeconfig=./ns1-tkg2-kubeconfig -o wide
NAME                                     STATUS   ROLES    AGE   VERSION             INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                 KERNEL-VERSION       CONTAINER-RUNTIME
ns1-tkg2-control-plane-28ddq             Ready    master   14d   v1.18.10+vmware.1   10.244.1.98    <none>        VMware Photon OS/Linux   4.19.154-3.ph3-esx   containerd://1.3.4
ns1-tkg2-workers-4ctxt-696fddf9d-f5xrw   Ready    <none>   14d   v1.18.10+vmware.1   10.244.1.100   <none>        VMware Photon OS/Linux   4.19.154-3.ph3-esx   containerd://1.3.4
ns1-tkg2-workers-4ctxt-696fddf9d-trrsx   Ready    <none>   14d   v1.18.10+vmware.1   10.244.1.99    <none>        VMware Photon OS/Linux   4.19.154-3.ph3-esx   containerd://1.3.4

ubuntu@ubuntu-455:~/workspace$ k get nodes --kubeconfig=./ns1-tkg1-kubeconfig -o wide
NAME                                      STATUS   ROLES    AGE    VERSION             INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                 KERNEL-VERSION       CONTAINER-RUNTIME
ns1-tkg1-control-plane-wwhfp              Ready    master   7d7h   v1.18.10+vmware.1   10.244.1.66   <none>        VMware Photon OS/Linux   4.19.154-3.ph3-esx   containerd://1.3.4
ns1-tkg1-workers-6r4l6-569ff87f5b-fjlpx   Ready    <none>   7d7h   v1.18.10+vmware.1   10.244.1.67   <none>        VMware Photon OS/Linux   4.19.154-3.ph3-esx   containerd://1.3.4
ns1-tkg1-workers-6r4l6-569ff87f5b-j4g8z   Ready    <none>   7d7h   v1.18.10+vmware.1   10.244.1.69   <none>        VMware Photon OS/Linux   4.19.154-3.ph3-esx   containerd://1.3.4
ns1-tkg1-workers-6r4l6-569ff87f5b-qppmt   Ready    <none>   7d7h   v1.18.10+vmware.1   10.244.1.68   <none>        VMware Photon OS/Linux   4.19.154-3.ph3-esx   containerd://1.3.4
```
or export to KUBECONFIG
```
ubuntu@ubuntu-455:~/workspace$ export KUBECONFIG=./ns1-tkg2-kubeconfig

ubuntu@ubuntu-455:~/workspace$ k get pods
NAME                              READY   STATUS    RESTARTS   AGE
minio-operator-78b4f47796-g247k   1/1     Running   0          14d
nginx-app2-99b5db6c8-hf4xw        1/1     Running   0          3d5h


ubuntu@ubuntu-455:~/workspace$ export KUBECONFIG=./ns1-tkg1-kubeconfig
ubuntu@ubuntu-455:~/workspace$ k get all
NAME          READY   STATUS      RESTARTS   AGE
pod/busybox   0/1     Completed   0          2d8h

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP    7d7h
service/supervisor   ClusterIP   None         <none>        6443/TCP   7d7h
```
