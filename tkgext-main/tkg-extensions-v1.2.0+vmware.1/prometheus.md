https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.2/vmware-tanzu-kubernetes-grid-12/GUID-extensions-monitoring.html



1. Create namespace for extension

    ```sh
    kubectl apply -f extentions/monitoring/prometheus/namespace-role.yaml
    ```

2. Copy `<extension-name>-data-values.yaml.example` to `<extension-name>-data-values.yaml` and
   Configure data values required for the extension in `<extension-name>-data-values.yaml`. <br>
   rather copy ./monitoring/prometheus/values.yaml for complete set
   ``` sh
   cp ./monitoring/prometheus/values.yaml ./extensions/monitoring/prometheus/vsphere/prometheus-data-values.yaml
   ```

2. Edit data-values.yaml 
vi ./extensions/monitoring/prometheus/vsphere/prometheus-data-values.yaml

```yaml      
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


        alerting:                                           #!---- around line 211 
          alertmanagers:
          - scheme: http
            static_configs:
            - targets:
              - "prometheus-alertmanager.tanzu-system-monitoring.svc:80"  #! alermanager service listens on port 80.


  ...
  alertmanager:  #!---- around line  908 
    ...
    #@overlay/replace                                  #! <============ put this to prevent ytt errors.
    config:
      slack_demo:
        name: slack_demo
        slack_configs: []
      email_receiver:
        name: email-receiver
        email_configs:                                #! optionally add email config
        - to: custom-email@tanzu.com
          send_resolved: false
          from: from-email@tanzu.com
          smarthost: smtp.eample.com:25
          require_tls: false

```

3. Create a secret with data values
   ```sh
   # create new
   kubectl create secret generic prometheus-data-values --from-file=values.yaml=./extensions/monitoring/prometheus/vsphere/prometheus-data-values.yaml -n tanzu-system-monitoring

   # for replace
   kubectl create secret generic prometheus-data-values --from-file=values.yaml=./extensions/monitoring/prometheus/vsphere/prometheus-data-values.yaml -n tanzu-system-monitoring -o yaml --dry-run | kubectl replace -f-

   # verify
   kubectl get secret  prometheus-data-values -n tanzu-system-monitoring -o 'go-template={{ index .data "values.yaml" }}' | base64 -d 
   ```
   
   test if contour templates are rendered correctly
   ```sh
   ytt --ignore-unknown-comments -f common/ -f monitoring/prometheus/  -f ./extensions/monitoring/prometheus/vsphere/prometheus-data-values.yaml  -v infrastructure_provider=vsphere 
   ```


4. Edit extension

    there are some modification on extension.
    
    refer to  https://github.com/myminseok/vmware-docs/blob/main/tkgext-main/tkg-extensions-v1.2.0%2Bvmware.1/prometheus-extension-custom.yaml

    ```
    ...

                update-alertmanager-deployment.yml: |
                  #@ load("@ytt:overlay", "overlay")
                  #@overlay/match by=overlay.subset({"kind": "Deployment", "metadata": {"name": "prometheus-alertmanager"}})
                  ---
                  spec:
                    template:
                      spec:
                        containers:
                        #@overlay/replace
                        #@overlay/match by="name"
                        - name: prometheus-alertmanager
                          image: "prom/alertmanager:v0.20.0"
                          imagePullPolicy: "IfNotPresent"
                          args:
                            - --config.file=/etc/config/alertmanager.yml
                            - --storage.path=/data
                            - --cluster.listen-address=                        #! add this line to disable alertmanager cluster feature. sometimes alertmanager pod fails to start due to cluster feature enabled.
                           
    ```
    
5. Deploy extension  

    ```sh 
    kubectl apply -f ./extensions/monitoring/prometheus/prometheus-extension.yaml
    
    ```


6. Check status of an extension

   App status should change to `Reconcile Succeeded` once extension is deployed successfully
   
   View detailed status

    ```sh
    kubectl get app prometheus -n tanzu-system-monitoring -o yaml -w
    kubectl get all -n tanzu-system-monitoring
    kubectl get httpproxy -n  tanzu-system-monitoring
    
    ```

