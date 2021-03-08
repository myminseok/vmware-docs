https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.2/vmware-tanzu-kubernetes-grid-12/GUID-extensions-index.html#ext-prereqs


## Prerequisites

* Workload cluster deployed.
* ytt installed (<https://github.com/k14s/ytt/releases>)
* kapp installed (<https://github.com/k14s/kapp/releases>)

### Deploy prometheus extension

1. Install TMC's extension manager

    ```sh
    kubectl apply -f extensions/tmc-extension-manager.yaml
    ```

2. Install kapp-controller
If the extension manifest pulls the image from a registry with a self-signed certificate, configure the Kapp controller(extensions/kapp-controller.yaml) to trust the registry.

    ```sh
    kubectl apply -f extensions/kapp-controller.yaml
    ```
```
kubectl get pods -A | grep tmc

vmware-system-tmc              extension-manager-7cf98d87b-hvk9g                        1/1     Running   0          6m12s
vmware-system-tmc              kapp-controller-6dbd776cc4-4sz8w                         1/1     Running   0          6m6s
```

3. Deploy cert-manager if its not already installed
Dex and Fluent Bit do not use cert-manager
    ```sh
    kubectl apply -f cert-manager/
    ```
