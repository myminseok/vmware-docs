https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/2.3/using-tkg/workload-packages-prometheus.html#access-the-prometheus-dashboard-13

https://prometheus.io/docs/prometheus/2.38/configuration/https/

https://github.com/prometheus/prometheus/blob/release-2.47/documentation/examples/web-config.yml


tanzu package install prometheus --package prometheus.tanzu.vmware.com --version 2.27.0+vmware.2-tkg.1 -n my-packages --values-file ./prometheus-values.yml


k logs deployment.apps/extension-manager -n vmware-system-tmc -f
k get deployment.apps/prometheus-server -n tanzu-system-monitoring -o yaml > prometheus-deploy.yml

kubectl -n tanzu-system-monitoring delete -f prometheus-configmap.yml
kubectl -n tanzu-system-monitoring apply -f prometheus-configmap.yml

kubectl -n my-packages delete secret overlay-prometheus
kubectl -n my-packages create secret generic overlay-prometheus -o yaml --dry-run=client --from-file=overlay-prometheus.yml | kubectl apply -f -
kubectl -n my-packages annotate PackageInstall prometheus ext.packaging.carvel.dev/ytt-paths-from-secret-name.1=overlay-prometheus


k get packageinstall -n my-packages  prometheus -o yaml

k delete deployment.apps/prometheus-server -n tanzu-system-monitoring

k get deployment.apps/prometheus-server -n tanzu-system-monitoring -o yaml 

k logs deployment.apps/prometheus-server -n tanzu-system-monitoring --all-containers

k get all -n tanzu-system-monitoring

k get all -n vmware-system-tmc

tanzu package installed kick -n my-packages prometheus

tanzu package installed delete prometheus --namespace my-packages

k port-forward service/prometheus-server 8080:80 -n tanzu-system-monitoring