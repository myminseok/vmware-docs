## update vsphere thumbprint (manual)

```
kubectl config use-context mgmt-admin@mgmt
kubectl get cm vsphere-cloud-config -n kube-system -o yaml
apiVersion: v1
data:
  vsphere.conf: |
    [Global]
    secret-name = "cloud-provider-vsphere-credentials"
    secret-namespace = "kube-system"
    thumbprint = "27:8F:1B:9A:F2:DC:20:BA:67:97:E1:C6:AE:51:07:48:B0:D4:6A:43"
    [VirtualCenter "vcenter.lab.pcfdemo.net"]
    datacenters = "/Datacenter"
    thumbprint = "27:8F:1B:9A:F2:DC:20:BA:67:97:E1:C6:AE:51:07:48:B0:D4:6A:43"
    
kubectl edit cm vsphere-cloud-config -n kube-system 
```
## update vsphere credential
```
tanzu management-cluster credentials update

tanzu cluster credentials update CLUSTER_NAME
```
https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-cluster-lifecycle-secrets.html#update-management-and-workload-cluster-credentials-vsphere-0

## update ntp,hosts (after cluster creation)
edit KubeadmConfigTemplate.spec.template.spec.preKubeadmCommands 
```
kubectl config use-context mgmt-admin@mgmt

kubectl get KubeadmConfigTemplate
NAME             AGE
tkc-noavi-md-0   155m

kubectl edit KubeadmConfigTemplate tkc-noavi-md-0
```
- recreate nodes(TBD)

- https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-tanzu-k8s-clusters-config-plans.html#configuring-ntp-without-dhcp-option-42-vsphere-7



## update trusted CA (after cluster creation) 


```
kubectl edit KubeadmConfigTemplate tkc-noavi-md-0

...

spec:
  template:
    spec:
      files:
      - content: 
        encoding: base64
        path: /etc/containerd/infra-harbor.lab.pcfdemo.net.crt
        permissions: "0444"
      joinConfiguration:
        nodeRegistration:
          criSocket: /var/run/containerd/containerd.sock
          kubeletExtraArgs:
            cloud-provider: external
            tls-cipher-suites: 
          name: '{{ ds.meta_data.hostname }}'
      preKubeadmCommands:
      - hostname "{{ ds.meta_data.hostname }}"
      - echo "::1         ipv6-localhost ipv6-loopback" >/etc/hosts
      - echo "127.0.0.1   localhost" >>/etc/hosts
      - echo "127.0.0.1   {{ ds.meta_data.hostname }}" >>/etc/hosts
      - echo "{{ ds.meta_data.hostname }}" >/etc/hostname
      - echo '[plugins."io.containerd.grpc.v1.cri".registry.configs."infra-harbor.lab.pcfdemo.net".tls]'
        >> /etc/containerd/config.toml
      - echo '  ca_file = "/etc/containerd/infra-harbor.lab.pcfdemo.net.crt"' >> /etc/containerd/config.toml
      - systemctl restart containerd
      - sed -i 's|".*/pause|"infra-harbor.lab.pcfdemo.net/tkg/pause|' /etc/containerd/config.toml
      - systemctl restart containerd
```
https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-cluster-lifecycle-secrets.html#custom-ca


```
kubectl config use-context mgmt-admin@mgmt

kubectl get KubeadmControlPlane
NAME                      INITIALIZED   API SERVER AVAILABLE   VERSION            REPLICAS   READY   UPDATED   UNAVAILABLE
tkc-noavi-control-plane   true          true                   v1.21.2+vmware.1   1          1       1

kubectl edit KubeadmControlPlane tkc-noavi-control-plane 

```

## k8s api-server certificate
k8s certificates is updated automatically when upgrading cluster. but can be done manually using kubeadm on controlplane node.

https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/

```
# in control plane VM
sudo su

kubeadm certs check-expiration

CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
admin.conf                 Dec 13, 2022 12:10 UTC   335d                                    no
apiserver                  Dec 13, 2022 12:10 UTC   335d            ca                      no
apiserver-etcd-client      Dec 13, 2022 12:10 UTC   335d            etcd-ca                 no
apiserver-kubelet-client   Dec 13, 2022 12:10 UTC   335d            ca                      no
controller-manager.conf    Dec 13, 2022 12:10 UTC   335d                                    no
etcd-healthcheck-client    Dec 13, 2022 12:10 UTC   335d            etcd-ca                 no
etcd-peer                  Dec 13, 2022 12:10 UTC   335d            etcd-ca                 no
etcd-server                Dec 13, 2022 12:10 UTC   335d            etcd-ca                 no
front-proxy-client         Dec 13, 2022 12:10 UTC   335d            front-proxy-ca          no
scheduler.conf             Dec 13, 2022 12:10 UTC   335d                                    no

CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
ca                      Dec 11, 2031 12:07 UTC   9y              no
etcd-ca                 Dec 11, 2031 12:07 UTC   9y              no
front-proxy-ca          Dec 11, 2031 12:07 UTC   9y              no
root@mgmt-control-plane-l764z:/home/capv# kubeadm certs renew -h
This command is not meant to be run on its own. See list of available subcommands.




kubeadm certs renew all

```

