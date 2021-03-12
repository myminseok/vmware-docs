https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.2/vmware-tanzu-kubernetes-grid-12/GUID-extensions-grafana.html




1. Copy data values.yml

    Copy ./monitoring/grefana/values.yaml for complete set
    ``` sh
    cp ./monitoring/grafana/values.yaml ./extensions/monitoring/grafana/vsphere/grafana-data-values.yaml
    ```

2. Edit data-values.yaml 

   Configure data values required for the extension in `<extension-name>-data-values.yaml`.
    
    vi ./extensions/monitoring/grafana/vsphere/grafana-data-values.yaml

    ```yaml      
    #@data/values
    #@overlay/match-child-defaults missing_ok=True
    ---

    monitoring:
      namespace: "tanzu-system-monitoring"
      create_namespace: false

      grafana:
        service_account_name: "grafana"
        cluster_role_name: "grafana-clusterrole"
        #@overlay/replace                                 #! <============ put this to prevent ytt errors.
        cluster_role:
          apiGroups: [""]
          resources: ["configmaps", "secrets"]
          verbs: ["get", "watch", "list"]
          
        secret:
          type: "Opaque"
          admin_user: "YWRtaW4="
          admin_password: "bXlwYXNzd29yZA=="             #! echo -n 'mypassword' | base64
      
    ```
    
    test if contour templates are rendered correctly
    ```sh
    ytt --ignore-unknown-comments -f common/ -f monitoring/grafana/  -f ./extensions/monitoring/grafana/vsphere/grafana-data-values.yaml  -v infrastructure_provider=vsphere 
    ```


3. Create namespace for extension

    ```sh
    kubectl apply -f extentions/monitoring/grafana/namespace-role.yaml
    ```
    
4. Create a secret with data values
    ```sh
    # create new
    kubectl create secret generic grafana-data-values --from-file=values.yaml=./extensions/monitoring/grafana/vsphere/grafana-data-values.yaml -n tanzu-system-monitoring

    # for replace
    kubectl create secret generic grafana-data-values --from-file=values.yaml=./extensions/monitoring/grafana/vsphere/grafana-data-values.yaml -n tanzu-system-monitoring -o yaml --dry-run | kubectl replace -f-

    # verify
    kubectl get secret  grafana-data-values -n tanzu-system-monitoring -o 'go-template={{ index .data "values.yaml" }}' | base64 -d 
    ```
   


5. Edit extension

    if required, modify  extension.

6. Deploy extension  

    ```sh 
    kubectl apply -f ./extensions/monitoring/prometheus/prometheus-extension.yaml
    
    ```

7. Check status of an extension

   App status should change to `Reconcile Succeeded` once extension is deployed successfully
   
   View detailed status

    ```sh
    kubectl get app grefana -n tanzu-system-monitoring -o yaml -w
    kubectl get all -n tanzu-system-monitoring
    kubectl get httpproxy -n  tanzu-system-monitoring
    
    ```

