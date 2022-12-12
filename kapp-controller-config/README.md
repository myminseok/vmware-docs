# Applying kapp-controller-config on deploying tkc. 

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
https://github.com/myminseok/vmware-docs/blob/main/kapp-controller-config/update-after-TKC-deployment.md
