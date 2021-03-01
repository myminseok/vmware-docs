
# Provision Tanzu Kubernetes Cluster
https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-0C2A88B3-6CB8-4495-B707-43710B94C7F6.html



# 
https://github.com/dstamen/Kubernetes



## PSP
```
kubectl create clusterrolebinding psp:authenticated  --clusterrole=psp:vmware-system-privileged --group=system:authenticated


kubectl get clusterrolebinding | grep psp
psp:authenticated                                                    ClusterRole/psp:vmware-system-privileged

```