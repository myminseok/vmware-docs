
# Provision Tanzu Kubernetes Cluster
https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-0C2A88B3-6CB8-4495-B707-43710B94C7F6.html



# samples
https://github.com/dstamen/Kubernetes



## PSP
https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-4CCDBB85-2770-4FB8-BF0E-5146B45C9543.html
```
kubectl create clusterrolebinding default-tkg-admin-privileged-binding --clusterrole=psp:vmware-system-privileged --group=system:authenticated


kubectl get clusterrolebinding | grep psp
psp:authenticated                                                    ClusterRole/psp:vmware-system-privileged

```
