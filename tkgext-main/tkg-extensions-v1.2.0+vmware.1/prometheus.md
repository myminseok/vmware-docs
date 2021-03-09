https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.2/vmware-tanzu-kubernetes-grid-12/GUID-extensions-monitoring.html



1. Create namespace for extension

    ```sh
    kubectl apply -f extentions/monitoring/prometheus/namespace-role.yaml
    ```

2. Copy `<extension-name>-data-values.yaml.example` to `<extension-name>-data-values.yaml` and
   Configure data values required for the extension in `<extension-name>-data-values.yaml`

   ```sh
   cp <extension-name>-data-values.yaml.example <extension-name>-data-values.yaml
   ```

   ```
   cp ./extensions/monitoring/prometheus/vsphere/prometheus-data-values.yaml.example ./extensions/monitoring/prometheus/vsphere/prometheus-data-values.yaml
   ```

   edit data-values.yaml 
   - referencing monitoring/prometheus/values.yml
   - put private harbor url 
   
   ```
#@data/values
#@overlay/match-child-defaults missing_ok=True
---
infrastructure_provider: "vsphere"
monitoring:
  prometheus_server:
    image:
      name: "prometheus"
      tag: "v2.18.1_vmware.1"
      repository: "registry.tkg.vmware.run/prometheus"
  alertmanager:
    image:
      repository: registry.tkg.vmware.run/prometheus
  kube_state_metrics:
    image:
      repository: registry.tkg.vmware.run/prometheus
  node_exporter:
    image:
      repository: registry.tkg.vmware.run/prometheus
  pushgateway:
    image:
      repository: registry.tkg.vmware.run/prometheus
  cadvisor:
    image:
      repository: registry.tkg.vmware.run/prometheus
  prometheus_server_configmap_reload:
    image:
      repository: registry.tkg.vmware.run/prometheus
  prometheus_server_init_container:
    image:
      repository: registry.tkg.vmware.run/prometheus
      ```

3. Create a secret with data values

   ```sh
   kubectl create secret generic <extension-name>-data-values --from-file=values.yaml=<extension-name>-data-values.yaml -n <extension-namespace>
   ```

   ```
   kubectl create secret generic prometheus-data-values --from-file=values.yaml=./extensions/monitoring/prometheus/vsphere/prometheus-data-values.yaml -n tanzu-system-monitoring


   kubectl create secret generic prometheus-data-values --from-file=values.yaml=./extensions/monitoring/prometheus/vsphere/prometheus-data-values.yaml -n tanzu-system-monitoring -o yaml --dry-run | kubectl replace -f-


   kubectl get secret  prometheus-data-values -n tanzu-system-monitoring -o 'go-template={{ index .data "values.yaml" }}' | base64 -d 
   ```

   check  deployment integrity
   ```
   ytt --ignore-unknown-comments -f common/ -f monitoring/prometheus/  -f ./extensions/monitoring/prometheus/vsphere/prometheus-data-values.yaml  -v infrastructure_provider=vsphere 
   ```


4. Deploy extensions

    ```sh
    kubectl apply -f <extension-name>-extension.yaml
    ```
    ```
    kubectl apply -f ./extensions/monitoring/prometheus/prometheus-extension.yaml
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
    kubectl get app prometheus -n tanzu-system-monitoring -o yaml -w
    kubectl get all -n tanzu-system-monitoring
    ```

6. exposing service
prometheus-server
```

cat  > ingress-monitoring.yml <<EOF

apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: selfsigned-issuer
    kubernetes.io/ingress.allow-http: "true"
  name: prometheus-server-ingress
  namespace: tanzu-system-monitoring
spec:
  tls:
  - hosts:
    - prometheus.tanzu.com
    secretName: prometheus-server-tls
  rules:
  - host: prometheus.tanzu.com
    http:
      paths:
      - backend:
          serviceName: prometheus-server
          servicePort: 80
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: selfsigned-issuer
    kubernetes.io/ingress.allow-http: "true"
  name: prometheus-alertmanager-ingress
  namespace: tanzu-system-monitoring
spec:
  tls:
  - hosts:
    - alertmanager.tanzu.com
    secretName: prometheus-alertmanager-tls
  rules:
  - host: alertmanager.tanzu.com
    http:
      paths:
      - backend:
          serviceName: prometheus-alertmanager
          servicePort: 80
```
