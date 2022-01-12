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
