https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.2/vmware-tanzu-kubernetes-grid-12/GUID-extensions-ingress-contour.html



1. Create namespace for extension

    ```sh
    kubectl apply -f extentions/ingress/contour/namespace-role.yaml
    ```

2. Copy `<extension-name>-data-values.yaml.example` to `<extension-name>-data-values.yaml` and
   Configure data values required for the extension in `<extension-name>-data-values.yaml`

   ```sh
   cp <extension-name>-data-values.yaml.example <extension-name>-data-values.yaml
   ```

   ```
  cp ./extensions/ingress/contour/vsphere/contour-data-values.yaml.example ./extensions/ingress/contour/vsphere/contour-data-values.yaml

   ```
  edit data-values.yaml 
   - referencing monitoring/prometheus/values.yml
   - put private harbor url 
```
#@data/values
#@overlay/match-child-defaults missing_ok=True
---
infrastructure_provider: "vsphere"
contour:
  image:
    repository: myregistry.tkg.vmware.run
envoy:
  image:
    repository: myregistry.tkg.vmware.run
  service:
    type: LoadBalancer
    externalTrafficPolicy: Cluster  #<-- envoy LB
    disableWait: false
  loglevel: info

```

3. Create a secret with data values

   ```sh
   kubectl create secret generic <extension-name>-data-values --from-file=values.yaml=<extension-name>-data-values.yaml -n <extension-namespace>
   ```

   ```
 
   kubectl create secret generic contour-data-values --from-file=values.yaml=./extensions/ingress/contour/vsphere/contour-data-values.yaml -n tanzu-system-ingress


   kubectl create secret generic contour-data-values --from-file=values.yaml=./extensions/ingress/contour/vsphere/contour-data-values.yaml -n tanzu-system-ingress -o yaml --dry-run=client | kubectl replace -f -


   kubectl get secret  contour-data-values -n tanzu-system-ingress -o 'go-template={{ index .data "values.yaml" }}' | base64 -d 
   ```

   check  deployment integrity
   ```
   ytt --ignore-unknown-comments -f common/ -f ingress/contour/  -f ./extensions/ingress/contour/vsphere/contour-data-values.yaml  -v infrastructure_provider=vsphere 
   ```


4. Deploy extensions

    ```sh
    kubectl apply -f <extension-name>-extension.yaml
    ```
    ```
    kubectl apply -f ./extensions/ingress/contour/contour-extension.yaml
    
    ```


5. Retrieve status of an extension

    ```sh
    kubectl get extension <extension-name> -n <extension-namespace>
    kubectl get app <extension-name> -n <extension-namespace>
    ```

   App status should change to `Reconcile Succeeded` once extension is deployed successfully

   View detailed status

   ```sh
   kubectl get app <extension-name> -n <extension-namespace> -o yaml
   ```

    ```
    kubectl get app contour -n tanzu-system-ingress -o yaml -w
    kubectl get all -n tanzu-system-ingress
    ```
