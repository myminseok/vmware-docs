# Applying kapp-controller-config on deploying tkc. 
updating kapp-controller-config on workload cluster by just updating addon on mgmt cluster.
on workload cluster., kapp controller init fails due to needed CA is not there or need to update kapp-controller-config secret(configmap) 

ref: https://carvel.dev/kapp-controller/docs/v0.42.0/controller-config/


### apply overlay.
```
cp tkg-custom-ca.pem ~/.config/tanzu/tkg/providers/ytt/02_addons/kapp-controller/tkg-custom-ca.pem

cp update-kapp-controller_addon_data.lib.yaml ~/.config/tanzu/tkg/providers/ytt/02_addons/kapp-controller/kapp-controller_addon_data.lib.yaml
```
### deploy TKC

### verify kapp-controller-data-values in mgmt cluster
```
kubectl --context mgmt-admin@mgmt get secret tkc-run-kapp-controller-data-values -o jsonpath='{.data.values\.yaml}' | base64 -d
```


# Updating kapp-controller-config after deploying tkc. 

### 1 fetch target cluster kapp-controller-addon. for example workload clsuter name is 'tkc-view-cluster' then, 
```
kubectl --context mgmt-admin@mgmt  get secret -n default | grep kapp
tkc-iterator-cluster-kapp-controller-addon                     tkg.tanzu.vmware.com/addon             1      25d
tkc-iterator-cluster-kapp-controller-data-values               Opaque                                 1      25d
tkc-shared-cluster-kapp-controller-addon                       tkg.tanzu.vmware.com/addon             1      26d
tkc-shared-cluster-kapp-controller-data-values                 Opaque                                 1      26d
tkc-view-cluster-kapp-controller-addon                         tkg.tanzu.vmware.com/addon             1      7h37m.    < --- target secerte CA
tkc-view-cluster-kapp-controller-data-values                   Opaque                                 1      7h36m
```
### 2 fetch tkc-view-cluster-kapp-controller-data-values from addon
```
kubectl --context mgmt-admin@mgmt get secret tkc-view-cluster-kapp-controller-data-values -o yaml -o jsonpath='{.data.values\.yaml}' | base64 --decode
kubectl --context mgmt-admin@mgmt get secret tkc-view-cluster-kapp-controller-data-values -o yaml -o jsonpath='{.data.values\.yaml}' | base64 --decode > tkc-view-cluster-kapp-controller-data-values.yaml
```

### 3 apply to tkc-view-cluster-kapp-controller-addon
```
cat tkc-view-kapp-controller-data-values.yml | base64 -w0
```

```
kubectl --context mgmt-admin@mgmt edit secret tkc-view-cluster-kapp-controller-addon
```
and paste the based encoded value.
```
apiVersion: v1
data:
  values.yaml: PASTE_HERE 
```
```
kubectl patch --context mgmt-admin@mgmt app/tkc-view-kapp-controller -n default -p '{"spec":{"paused":true}}' --type=merge
kubectl patch --context mgmt-admin@mgmt app/tkc-view-kapp-controller -n default -p '{"spec":{"paused":false}}' --type=merge
```


### 4 verify kapp-controller-config on workload cluster 
wait for 2-3 min to be updated.
```
kubectl --context tkc-view-cluster-admin@tkc-view-cluster delete cm kapp-controller-config -n tkg-system
NAME                     DATA   AGE
kapp-controller-config   5      102s

kubectl --context tkc-view-cluster-admin@tkc-view-cluster get cm kapp-controller-config -n tkg-system -o yaml
```


