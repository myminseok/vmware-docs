
# Install contour extension

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

   Test if contour templates are rendered correctly

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


## Update contour extension

1. Get contour data values from secret

    ```sh
    kubectl get secret contour-data-values -n tanzu-system-ingress -o 'go-template={{ index .data "values.yaml" }}' | base64 -d > contour-data-values.yaml
    ```

2. Update contour data values in contour-data-values.yaml

3. Update contour data values secret

    ```sh
    kubectl create secret generic contour-data-values --from-file=values.yaml=contour-data-values.yaml -n tanzu-system-ingress -o yaml --dry-run | kubectl replace -f-
    ```

   Contour extension will be reconciled again with the above data values

   **NOTE:**
   By default, kapp-controller will sync apps every 5 minutes. So, the update should take effect in <= 5 minutes.
   If you want the update to take effect immediately, change syncPeriod in `contour-extension.yaml` to a lesser value
   and apply contour extension `kubectl apply -f contour-extension.yaml`.

4. Refer to `Retrieve status of an extension` in [deploy contour extension](#deploy-contour-extension) to retrieve the status of an extension

## Delete contour extension

1. Delete contour extension

    ```sh
    kubectl delete -f contour-extension.yaml
    kubectl delete app contour -n tanzu-system-ingress
    ```

2. Refer to `Retrieve status of an extension` in [deploy contour extension](#deploy-contour-extension) to retrieve the status of an extension

   If extension is deleted successfully, then get of contour app should return `Not Found`

3. Delete contour namespace

   **NOTE: Do not delete namespace-role.yaml before app is deleted fully, as it will lead to errors due to service account used by kapp-controller being deleted**

    ```sh
    kubectl delete -f namespace-role.yaml
    ```

# Upgrade contour deployment to contour extension

1. Get contour configmap

    ```sh
    kubectl get configmap contour -n tanzu-system-ingress -o 'go-template={{ index .data "contour.yaml" }}' > contour-configmap.yaml
    ```

2. Delete existing contour deployment

    ```sh
    kubectl delete namespace tanzu-system-ingress
    ```

3. Follow steps in [Deploy contour extension](#deploy-contour-extension) to deploy contour extension


# Test Contour

### Envoy exposed using service type:NodePort

1. Deploy test pods and services

    ```sh
    kubectl apply -f ingress/examples/common/
    ```

2. Deploy kubernetes ingress resource

    ```sh
    kubectl apply -f ingress/examples/https-ingress/
    ```

3. Add /etc/hosts entry mapping one of the worker node IP to foo.bar.com

    ```sh
    echo '<WORKER_NODE_IP> foo.bar.com' | sudo tee -a /etc/hosts > /dev/null
    ```

4. Get Envoy service https port (ENVOY_SERVICE_HTTPS_PORT)

   By default the Envoy service https port will be 443. If you explicitly specify `envoy.hostPort.enable=false`, run the following command to get the random port assigned by Kubernetes:

    ```sh
    kubectl get service envoy -n tanzu-system-ingress -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}'
    ```

5. Verify if the following URLs work

    ```sh
    https://foo.bar.com:<ENVOY_SERVICE_HTTPS_PORT>/foo
    https://foo.bar.com:<ENVOY_SERVICE_HTTPS_PORT>/bar
    ```

### Envoy exposed using service type: LoadBalancer

1. Deploy test pods and services

    ```sh
    kubectl apply -f ingress/examples/common/
    ```

2. Deploy kubernetes ingress resource

    ```sh
    kubectl apply -f ingress/examples/https-ingress/
    ```

3. Get Envoy service loadbalancer hostname (ENVOY_SERVICE_LB_HOSTNAME)

    ```sh
    kubectl get service envoy -n tanzu-system-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
    ```

4. Get Envoy service loadbalancer ip (ENVOY_SERVICE_LB_IP)

    ```sh
    nslookup <ENVOY_SERVICE_LB_HOSTNAME>
    ```

5. Add /etc/hosts entry mapping Envoy service loadbalancer ip to foo.bar.com

    ```sh
    echo '<ENVOY_SERVICE_LB_IP> foo.bar.com' | sudo tee -a /etc/hosts > /dev/null
    ```

6. Verify if the following URLs work

    ```sh
    https://foo.bar.com/foo
    https://foo.bar.com/bar
    ```

## Troubleshooting

### Access Envoy admin interface remotely

1. Get one of the pods that matches the Envoy daemonset

    ```sh
    ENVOY_POD=$(kubectl -n tanzu-system-ingress get pod -l app=envoy -o name | head -1)
    ```

2. Port forward to the Envoy pod

    ```sh
    kubectl -n tanzu-system-ingress port-forward $ENVOY_POD 9001
    ```

3. Navigate to URL to access Envoy admin interface

   ```sh
   http://127.0.0.1:9001/
   ```

### Visualizing Contour's internal directed acyclic graph (DAG)

1. Get one of the Contour pods

    ```sh
    CONTOUR_POD=$(kubectl -n tanzu-system-ingress get pod -l app=contour -o name | head -1)
    ```

2. Port forward to the Contour pod

    ```sh
    kubectl -n tanzu-system-ingress port-forward $CONTOUR_POD 6060
    ```

3. Download and store the DAG in png format

    ```sh
    curl localhost:6060/debug/dag | dot -T png > contour-dag.png
    ```

4. Open contour-dag.png to view the graph
