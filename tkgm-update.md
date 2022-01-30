
# TKGm 1.4

## Update vsphere credential
```
tanzu management-cluster credentials update

tanzu cluster credentials update CLUSTER_NAME
```
  
```
kubectl get secret cloud-provider-vsphere-credentials -n kube-system  -o yaml
```
```
apiVersion: v1
data:
  vcenter.lab.pcfdemo.net.password: xxxx
  vcenter.lab.pcfdemo.net.username: xxxx=
kind: Secret
```
  
https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-cluster-lifecycle-secrets.html#update-management-and-workload-cluster-credentials-vsphere-0

## update ntp,hosts, custom CA (after cluster creation)
- https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-tanzu-k8s-clusters-config-plans.html#configuring-ntp-without-dhcp-option-42-vsphere-7
- https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-cluster-lifecycle-secrets.html#custom-ca

### procedure
1) update KubeadmConfigTemplate, KubeadmControlPlane for next provision.
2) update KubeadmConfigs for existing clusters. this will recreate control-plane node
3) update machinedeployment for recreate worker node.

### 1) update KubeadmConfigTemplate, KubeadmControlPlane for next provision.
```
kubectl config use-context mgmt-admin@mgmt

kubectl get kubeadmconfigtemplate
NAME             AGE
tkc-noavi-md-0   10d

kubectl edit KubeadmConfigTemplate tkc-noavi-md-0

...

spec:
  template:
    spec:
      files:
      - content: LS0tLS1CRUdJTiBDRVJ...
        encoding: base64
        path: /etc/containerd/infra-harbor.lab.pcfdemo.net.crt
        permissions: "0444"
      - content: |
          -----BEGIN CERTIFICATE-----
          MIIDtDCCApygAwIBAgIUBRbNs4m+6QVRua3Kfjdz7O8CKw0wDQYJKoZIhvcNAQEL
          ...
          H5gBczpKPL74ZP1EauP1Lgv82Hjc+nNbJKX7UX/V8R+3cOLIaOjIKg==
          -----END CERTIFICATE-----
        owner: root:root
        path: /etc/ssl/certs/tkg-custom-ca.pem
        permissions: "0644"
      joinConfiguration:
        nodeRegistration:
          criSocket: /var/run/containerd/containerd.sock
          kubeletExtraArgs:
            cloud-provider: external
            tls-cipher-suites: TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_E...
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
      - '! which rehash_ca_certificates.sh 2>/dev/null || rehash_ca_certificates.sh'
      - '! which update-ca-certificates 2>/dev/null || (mv /etc/ssl/certs/tkg-custom-ca.pem
        /usr/local/share/ca-certificates/tkg-custom-ca.crt && update-ca-certificates)'
      - systemctl restart containerd
```


```
kubectl config use-context mgmt-admin@mgmt

kubectl get KubeadmControlPlane
NAME                      INITIALIZED   API SERVER AVAILABLE   VERSION            REPLICAS   READY   UPDATED   UNAVAILABLE
tkc-noavi-control-plane   true          true                   v1.21.2+vmware.1   1          1       1

kubectl edit KubeadmControlPlane tkc-noavi-control-plane 

spec:
  template:
    spec:
      files:
      - content: LS0tLS1CRUdJTiBDRVJUSUZJQ...
        encoding: base64
        path: /etc/containerd/infra-harbor.lab.pcfdemo.net.crt
        permissions: "0444"
      - content: |
          -----BEGIN CERTIFICATE-----
          MIIDtDCCApygAwIBAgIUBRbNs4m+6QVRua3Kfjdz7O8CKw0wDQYJKoZIhvcNAQEL
  ...
          H5gBczpKPL74ZP1EauP1Lgv82Hjc+nNbJKX7UX/V8R+3cOLIaOjIKg==
          -----END CERTIFICATE-----
        owner: root:root
        path: /etc/ssl/certs/tkg-custom-ca.pem
        permissions: "0644"
      joinConfiguration:
        nodeRegistration:
          criSocket: /var/run/containerd/containerd.sock
          kubeletExtraArgs:
            cloud-provider: external
            tls-cipher-suites: ...
          name: '{{ ds.meta_data.hostname }}'
      preKubeadmCommands:
      ...
      - '! which rehash_ca_certificates.sh 2>/dev/null || rehash_ca_certificates.sh'
      - '! which update-ca-certificates 2>/dev/null || (mv /etc/ssl/certs/tkg-custom-ca.pem
        /usr/local/share/ca-certificates/tkg-custom-ca.crt && update-ca-certificates)'
      - systemctl restart containerd
```
2) update KubeadmConfigs for existing clusters. this will recreate control-plane node
after patching tkc-noavi-control-plane kubeadmconfig, controlplane node will be rectreaed automatically, but worker node wonot. 
```
kubectl config use-context mgmt-admin@mgmt

kubectl get kubeadmconfigs
NAME                            AGE
tkc-noavi-control-plane-c8fwl   21m
tkc-noavi-md-0-2p7xh            11m
tkc-noavi-md-0-b74bl            13m
tkc-noavi-md-0-pww5f            9m16s
tkc-noavi-md-0-ttmtf            5m23s
tkc-noavi-md-0-tz5vl


spec:
  ...
  files:
  - content: LS0tLS1CRUdJTiBDRVJUSUZJQ...
        encoding: base64
        path: /etc/containerd/infra-harbor.lab.pcfdemo.net.crt
        permissions: "0444"
      - content: |
          -----BEGIN CERTIFICATE-----
          MIIDtDCCApygAwIBAgIUBRbNs4m+6QVRua3Kfjdz7O8CKw0wDQYJKoZIhvcNAQEL
  ...
          H5gBczpKPL74ZP1EauP1Lgv82Hjc+nNbJKX7UX/V8R+3cOLIaOjIKg==
          -----END CERTIFICATE-----
        owner: root:root
        path: /etc/ssl/certs/tkg-custom-ca.pem
        permissions: "0644"
      preKubeadmCommands:
      ...
      - '! which update-ca-certificates 2>/dev/null || (mv /etc/ssl/certs/tkg-custom-ca.pem
        /usr/local/share/ca-certificates/tkg-custom-ca.crt && update-ca-certificates)'
      - systemctl restart containerd
        
```

3) update machinedeployment for recreate worker node.
```
kubectl patch md tkc-noavi-md-0 --type merge --patch "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"date\":\"`date +'%s'`\"}}}}}"
```
```
kubectl get ma
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



## To update  vsphere thumbprint for MANAGEMENT cluster
###  WARINING: this is experimental. please donot apply this on production environment.

1. Update the secrets MGMT_CLUSTER_NAME-vsphere-cpi-addon in tkg-system namespace in MGMT CLUSTER
> replace CLUSTER_NAME with real cluster name.
```
kubectl config use-context mgmt-admin@mgmt
kubectl get secret -A | grep vsphere
export CLUSTER_NAME=mgmt
```
```
kubectl get secret  -n tkg-system $CLUSTER_NAME-vsphere-cpi-addon -o jsonpath='{.data.values\.yaml}' | base64 -d > $CLUSTER_NAME-vsphere-cpi-addon-values.yaml
```

> edit vsphere credentials
```
vi $CLUSTER_NAME-vsphere-cpi-addon-values.yaml
```

```
kubectl create secret generic $CLUSTER_NAME-vsphere-cpi-addon -n tkg-system --type=tkg.tanzu.vmware.com/addon --from-file=values.yaml=$CLUSTER_NAME-vsphere-cpi-addon-values.yaml --dry-run=client -o yaml | kubectl replace -f -
unset CLUSTER_NAME
```

2. vsphere-cpi-data-values in tkg-system namespace in MGMT CLUSTER
```
kubectl config use-context mgmt-admin@mgmt
kubectl get secret -A | grep vsphere
```
```
kubectl get secret  -n tkg-system vsphere-cpi-data-values  -o yaml -o jsonpath='{.data.values\.yaml}' | base64 -d > ./vsphere-cpi-data-values.yml
```
> edit vsphere credentials
```
vi ./vsphere-cpi-data-values.yml
```
```
kubectl create secret generic vsphere-cpi-data-values -n tkg-system --from-file=values.yaml=vsphere-cpi-data-values.yml --dry-run=client -o yaml | kubectl replace -f -
``` 

3. wait for reconciliation to update the configmap vsphere-cpi-data-values in kube-system and then delete the pod vsphere-cloud-controller-manager
check if updated.
> in a few seconds, it will be changed.
```
watch -n 5 kubectl get cm vsphere-cloud-config -n kube-system -o yaml
```
```
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
    
```

4. restart the pod vsphere-cloud-controller-manager
```
kubectl rollout restart daemonset.apps/vsphere-cloud-controller-manager -n kube-system
kubectl get po -A | grep vsphere-cloud-controller-manager
```
## To update vsphere thumbprint for WORKLOAD cluster

1. Update the secrets <workload-clustername>-vsphere-cpi-addon in tkg-system namespace
> set config to MGMT CLUSTER
> replace CLUSTER_NAME with you workload cluster name.
```
kubectl config use-context mgmt-admin@mgmt
kubectl get secret -A | grep vsphere
export CLUSTER_NAME=WORKLOAD_CLUSTER_NAME
```
```
kubectl get secret $CLUSTER_NAME-vsphere-cpi-addon -o jsonpath='{.data.values\.yaml}' | base64 -d > $CLUSTER_NAME-vsphere-cpi-addon-values.yaml
```
> edit vsphere credentials
```
vi $CLUSTER_NAME-vsphere-cpi-addon-values.yaml
```
```
kubectl create secret generic $CLUSTER_NAME-vsphere-cpi-addon --type=tkg.tanzu.vmware.com/addon --from-file=values.yaml=$CLUSTER_NAME-vsphere-cpi-addon-values.yaml --dry-run=client -o yaml | kubectl replace -f -
unset CLUSTER_NAME
```
  
2. vsphere-cpi-data-values in tkg-system namespace in WORKLOAD cluster
```
kubectl config use-context WORKLOAD_CLUSTER_NAME-admin@WORKLOAD_CLUSTER_NAME
```
```
kubectl get secret -A | grep vsphere
kubectl get secret  -n tkg-system vsphere-cpi-data-values  -o yaml -o jsonpath='{.data.values\.yaml}' | base64 -d > ./vsphere-cpi-data-values.yml
```
> edit vsphere credentials
```
vi ./vsphere-cpi-data-values.yml
```
```
kubectl create secret generic vsphere-cpi-data-values -n tkg-system --from-file=values.yaml=vsphere-cpi-data-values.yml --dry-run=client -o yaml | kubectl replace -f -
```  

3. wait for reconciliation to update the configmap and secret in kube-system 
```
kubectl get cm vsphere-cloud-config -n kube-system -o yaml
```
```
apiVersion: v1
data:
  vsphere.conf: |
    [Global]
    secret-name = "cloud-provider-vsphere-credentials"
    secret-namespace = "kube-system"
    insecure-flag = "1"
    [VirtualCenter "vcenter.lab.pcfdemo.net"]
    datacenters = "/Datacenter"
    insecure-flag = "1"
kind: ConfigMap
```
    
4. restart the pod vsphere-cloud-controller-manager
```
kubectl rollout restart daemonset.apps/vsphere-cloud-controller-manager -n kube-system
kubectl get po -A | grep vsphere-cloud-controller-manager
```
  
#### reference
  - https://github.com/vmware-tanzu/tanzu-framework/blob/main/pkg/v1/providers/ytt/02_addons/cpi/cpi_secret.yaml
  
  

