# assigning multiple NICs on k8s pod on TKGm


## scenarios
multi NIC is required on following scenarios.
1. outbound access from pod in k8s worker node to external resources such as DB, Storage, NFS on  external network which is outside of k8s worker node network.
2. due to security reason or reguration, pod to pod communcation inside of k8s cluster with isolated network might be required.



## Multux CN type and IP Address Management (IPAM) CNI testing results
1. macvlan cni type + host-local ipam type => host-local only knows how to assign IPs to pods on the same node. the pod on different worker node might have the same ip from the ipam pool. pod routable within the same worker node only.
2. ipvlan cni type + host-local ipam type => the same above.
3. ipvlan cni type + whereabouts ipam type =>  wehreabouts can assigns IP addresses cluster-wide.(https://github.com/vmware-tanzu/community-edition/tree/main/addons/packages/whereabouts/0.5.1). routable between any pod on other worker node in the k8s cluster.


## setting up
1. Prepare TKC wit multiple NICs on worker node.
create TKC manifest file(https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/vmware-tanzu-kubernetes-grid-15/GUID-tanzu-k8s-clusters-deploy.html#manifest)
```
tanzu cluster create my-cluster --file my-cluster-config.yaml --dry-run > my-cluster-manifest.yaml
```
and add additional nic to the my-cluster-manifest.yaml

```
---
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: VSphereMachineTemplate
metadata:
  name: my-cluster-worker
  namespace: default
spec:
  template:
    spec:
      cloneMode: fullClone
      datacenter: dc0
      datastore: sharedVmfs-0
      diskGiB: 40
      folder: folder0
      memoryMiB: 8192
      network:
        devices:
        - dhcp4: true
          networkName: /dc0/network/VM Network
        - dhcp4: true
          networkName: Your_vSphere_External_Network_Path
      numCPUs: 2
      resourcePool: rp0
      server: 10.191.150.63
      storagePolicyName: ""
      template: /dc0/vm/photon-3-kube-v1.22.3+vmware.1-tkg.3
```
deploy the tkc

```
kubectl config use-context mgmt-admin@mgmt
kubectl apply -f my-cluster-manifest.yaml
```
check the progress with various check points.
- k logs deploy/capv-controller-manager -n capv-system 
- k logs deploy/capi-controller-manager -n capi-system
- pod creation status on the TKC cluster

2. Multus CNI is installed in the TKC cluster
```
tanzu package available list multus-cni.tanzu.vmware.com -A


tanzu package available get multus-cni.tanzu.vmware.com/3.7.1+vmware.2-tkg.2 --values-schema -o yaml > multus-value-schema.yml

image_url=$(kubectl -n tanzu-package-repo-global get packages  multus-cni.tanzu.vmware.com.3.7.1+vmware.2-tkg.2 -o jsonpath='{.spec.template.spec.fetch[0].imgpkgBundle.image}')
imgpkg pull -b $image_url -o ./multus


cp ./multus/config/values.yaml multus-cni-values.yaml

yq -i eval '... comments=""' multus-cni-values.yaml


tanzu package install multus-cni \
	--package-name multus-cni.tanzu.vmware.com \
	--version 3.7.1+vmware.2-tkg.2 \
	--values-file multus-cni-values.yaml

tanzu package installed get multus-cni
NAME:                    multus-cni
PACKAGE-NAME:            multus-cni.tanzu.vmware.com
PACKAGE-VERSION:         3.7.1+vmware.2-tkg.2
STATUS:                  Reconcile succeeded
CONDITIONS:              [{ReconcileSucceeded True  }]
USEFUL-ERROR-MESSAGE:
```
3. whereabouts

```
tanzu package repository add tce-repo --url projects.registry.vmware.com/tce/main:0.10.0 --namespace tanzu-package-repo-global
tanzu package available list whereabouts.community.tanzu.vmware.com -A
tanzu package available get whereabouts.community.tanzu.vmware.com/0.5.0 --values-schema -o yaml > whereabouts-value-schama.yml

kubectl -n tanzu-package-repo-global get packages
image_url=$(kubectl -n tanzu-package-repo-global get packages  whereabouts.community.tanzu.vmware.com.0.5.0 -o jsonpath='{.spec.template.spec.fetch[0].imgpkgBundle.image}')
imgpkg pull -b $image_url -o ./whereabouts



tanzu package repository add tce-repo --url projects.registry.vmware.com/tce/main:0.10.0 --namespace tanzu-package-repo-global
tanzu package available list whereabouts.community.tanzu.vmware.com -A
tanzu package available get whereabouts.community.tanzu.vmware.com/0.5.0 --values-schema -o yaml
tanzu package install whereabout \
	--package-name   whereabouts.community.tanzu.vmware.com \
	--version 0.5.0


tanzu package installed get whereabout
NAME:                    whereabout
PACKAGE-NAME:            whereabouts.community.tanzu.vmware.com
PACKAGE-VERSION:         0.5.0
STATUS:                  Reconcile succeeded
CONDITIONS:              [{ReconcileSucceeded True  }]
USEFUL-ERROR-MESSAGE:

```

## testing

1. configure cni crd config
use ipvlan on second NIC on the worker node. ipam will use private pod network in this k8s cluster.
see https://github.com/vmware-tanzu/community-edition/tree/main/addons/packages/whereabouts/0.5.1

```
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: ipvlan-whereabouts-conf
spec:
  config: '{
      "cniVersion": "0.3.0",
      "type": "ipvlan",
      "master": "eth1",
      "ipam": {
        "type": "whereabouts",
        "range": "10.99.1.0/24",
        "range_start": "10.99.1.200",
        "range_end": "10.99.1.216",
        "gateway": "10.99.1.1"
      }
    }'
```
2. label worker node
```
k label node tkc-avi-md-0-bdc77b698-b8wx9 workerid=worker1

k label node tkc-avi-md-0-bdc77b698-x7ck6 workerid=worker2


k get nodes -o wide
NAME                           STATUS   ROLES                  AGE    VERSION            INTERNAL-IP     EXTERNAL-IP     OS-IMAGE                 KERNEL-VERSION   CONTAINER-RUNTIME
tkc-avi-control-plane-qrkdh    Ready    control-plane,master   5h1m   v1.22.5+vmware.1   192.168.0.161   192.168.0.161   VMware Photon OS/Linux   4.19.224-2.ph3   containerd://1.5.9
tkc-avi-md-0-bdc77b698-b8wx9   Ready    <none>                 5h     v1.22.5+vmware.1   192.168.0.115   192.168.0.115   VMware Photon OS/Linux   4.19.224-2.ph3   containerd://1.5.9
tkc-avi-md-0-bdc77b698-x7ck6   Ready    <none>                 179m   v1.22.5+vmware.1   192.168.0.151   192.168.0.151   VMware Photon OS/Linux   4.19.224-2.ph3   containerd://1.5.9


```

3. deploy deployment on per each worker node
use affinity rule and node labels. provision on each node.
```
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: busybox-deploy1
  name: busybox-deploy1
spec:
  replicas: 1 
  selector:
    matchLabels:
      app: busybox-deploy1
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: busybox-deploy1
      annotations:
        k8s.v1.cni.cncf.io/networks: ipvlan-whereabouts-conf
    spec:
      containers:
      - image: busybox
        name: pod
        command: ['sh','-c','sleep 4800']
        resources: {}
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            preference:
              matchExpressions:
              - key: workerid
                operator: In
                values:
                - worker1


```
verify ip assignment or troubleshooting
```
k describe pod busybox-deploy-95cb848fd-qn8p5

  Type    Reason          Age   From               Message
  ----    ------          ----  ----               -------
  Normal  Scheduled       55m   default-scheduler  Successfully assigned default/busybox1 to tkc-avi-md-0-bdc77b698-b8wx9
  Normal  AddedInterface  55m   multus             Add eth0 [100.96.1.137/24]
  Normal  AddedInterface  55m   multus             Add net1 [10.99.1.200/24] from default/ipvlan-whereabouts-conf
  Normal  Pulling         55m   kubelet            Pulling image "busybox"
  Normal  Pulled          55m   kubelet            Successfully pulled image "busybox" in 5.579220265s
  Normal  Created         55m   kubelet            Created container pod
  Normal  Started         55m   kubelet            Started container pod
```



```
root@ubuntu:/data/vmware-docs/multi-nic# k get pod -o wide
NAME                             READY   STATUS    RESTARTS   AGE     IP             NODE                           NOMINATED NODE   READINESS GATES
busybox1                         1/1     Running   0          52m     100.96.1.137   tkc-avi-md-0-bdc77b698-b8wx9   <none>           <none>
busybox2                         1/1     Running   0          52m     100.96.2.141   tkc-avi-md-0-bdc77b698-x7ck6   <none>           <none>
```


4. testing 
busybox1 
```
/ # ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
3: eth0@if142: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1450 qdisc noqueue
    link/ether 3e:e6:ca:ce:13:df brd ff:ff:ff:ff:ff:ff
    inet 100.96.1.137/24 brd 100.96.1.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::3ce6:caff:fece:13df/64 scope link
       valid_lft forever preferred_lft forever
4: net1@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
    link/ether 00:50:56:91:aa:06 brd ff:ff:ff:ff:ff:ff
    inet 10.99.1.200/24 brd 10.99.1.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fe80::50:5600:191:aa06/64 scope link
       valid_lft forever preferred_lft forever

/ # route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         100.96.1.1      0.0.0.0         UG    0      0        0 eth0
10.99.1.0       *               255.255.255.0   U     0      0        0 net1
100.96.1.0      *               255.255.255.0   U     0      0        0 eth0

```
busybox2
```
root@ubuntu:/data/vmware-docs/multi-nic# k exec -it busybox2 sh
/ # ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
3: eth0@if146: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1450 qdisc noqueue
    link/ether 26:d7:4b:fd:64:af brd ff:ff:ff:ff:ff:ff
    inet 100.96.2.141/24 brd 100.96.2.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::24d7:4bff:fefd:64af/64 scope link
       valid_lft forever preferred_lft forever
4: net1@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
    link/ether 00:50:56:91:44:5e brd ff:ff:ff:ff:ff:ff
    inet 10.99.1.201/24 brd 10.99.1.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fe80::50:5600:191:445e/64 scope link
       valid_lft forever preferred_lft forever
/ # route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         100.96.2.1      0.0.0.0         UG    0      0        0 eth0
10.99.1.0       *               255.255.255.0   U     0      0        0 net1
100.96.2.0      *               255.255.255.0   U     0      0        0 eth0



## route to worker node1
/ # ping 192.168.0.115
PING 192.168.0.115 (192.168.0.115): 56 data bytes
64 bytes from 192.168.0.115: seq=0 ttl=63 time=0.630 ms

## route to worker node2
/ # ping 192.168.0.151
PING 192.168.0.151 (192.168.0.151): 56 data bytes
64 bytes from 192.168.0.151: seq=0 ttl=64 time=0.856 ms


## route to pod on worker node1
/ # ping 10.99.1.200
PING 10.99.1.200 (10.99.1.200): 56 data bytes
64 bytes from 10.99.1.200: seq=0 ttl=64 time=0.295 ms

```





reference: https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/vmware-tanzu-kubernetes-grid-15/GUID-packages-cni-multus.html

