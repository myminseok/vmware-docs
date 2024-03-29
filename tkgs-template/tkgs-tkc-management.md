
# Provision Tanzu Kubernetes Cluster
https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-0C2A88B3-6CB8-4495-B707-43710B94C7F6.html

# samples
https://github.com/dstamen/Kubernetes

## Configure Pod Security 

#### TKG 1.24 and Earlier(PSP, Pod Security Policy Controller)
- https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-4CCDBB85-2770-4FB8-BF0E-5146B45C9543.html
- Configure Pod Security Policy for TKR 1.24 and Eariler https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-with-tanzu-tkg/GUID-3B7F5B44-E31D-4819-B166-C531D4ECAE7D.html
```
kubectl create clusterrolebinding default-tkg-admin-privileged-binding --clusterrole=psp:vmware-system-privileged --group=system:authenticated
```
```
kubectl get clusterrolebinding | grep psp
psp:authenticated                                                    ClusterRole/psp:vmware-system-privileged
```
#### TKR 1.25 and Later(PSA, Pod Security Admission Controller)
- https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-with-tanzu-tkg/GUID-B57DA879-89FD-4C34-8ADB-B21CB3AE67F6.html



## Certificates
- certificate list and validity : https://kb.vmware.com/s/article/89324
- rotate : https://kb.vmware.com/s/article/90627


## sample apps

https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-E217C538-2241-4FD9-9D67-6A54E97CA800.html