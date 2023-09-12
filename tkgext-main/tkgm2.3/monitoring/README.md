
https://prometheus.io/docs/prometheus/2.38/configuration/https/

https://github.com/prometheus/prometheus/blob/release-2.47/documentation/examples/web-config.yml

TKGS: https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-with-tanzu-tkg/GUID-02B52A07-BA85-4603-8EA4-B414499722C8.html


# on TKGm 2.3
https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/2.3/using-tkg/workload-packages-prometheus.html#access-the-prometheus-dashboard-13

k create ns tkg-system

tanzu package repository add tanzu-standard --url projects.registry.vmware.com/tkg/packages/standard/repo:v2023.7.13 -n tkg-system

tanzu package available list prometheus.tanzu.vmware.com -A

  NAMESPACE   NAME                         VERSION                RELEASED-AT
  tkg-system  prometheus.tanzu.vmware.com  2.27.0+vmware.1-tkg.1  2021-05-13 03:00:00 +0900 KST
  tkg-system  prometheus.tanzu.vmware.com  2.27.0+vmware.2-tkg.1  2021-05-13 03:00:00 +0900 KST
  tkg-system  prometheus.tanzu.vmware.com  2.36.2+vmware.1-tkg.1  2022-06-24 03:00:00 +0900 KST
  tkg-system  prometheus.tanzu.vmware.com  2.37.0+vmware.1-tkg.1  2022-10-26 03:00:00 +0900 KST
  tkg-system  prometheus.tanzu.vmware.com  2.37.0+vmware.2-tkg.1  2022-10-26 03:00:00 +0900 KST
  tkg-system  prometheus.tanzu.vmware.com  2.37.0+vmware.3-tkg.1  2022-10-26 03:00:00 +0900 KST
  tkg-system  prometheus.tanzu.vmware.com  2.43.0+vmware.2-tkg.1  2023-03-22 03:00:00 +0900 KST

tanzu package available get  prometheus.tanzu.vmware.com/2.43.0+vmware.2-tkg.1 -n tkg-system --default-values-file-output prometheus-values-2.43.yml


k create ns tanzu-system-monitoring
kubectl -n tanzu-system-monitoring delete -f prometheus-configmap.yml
kubectl -n tanzu-system-monitoring apply -f prometheus-configmap.yml

kubectl -n tkg-system  delete secret overlay-prometheus
kubectl -n tkg-system  create secret generic overlay-prometheus -o yaml --dry-run=client --from-file=overlay-prometheus.yml | kubectl apply -f -


tanzu package install prometheus --package prometheus.tanzu.vmware.com --version 2.43.0+vmware.2-tkg.1 -n tkg-system --values-file prometheus-values-2.43.yml

kubectl -n tkg-system  annotate PackageInstall prometheus ext.packaging.carvel.dev/ytt-paths-from-secret-name.1-

kubectl -n tkg-system  annotate PackageInstall prometheus ext.packaging.carvel.dev/ytt-paths-from-secret-name.1=overlay-prometheus

## k logs deployment.apps/extension-manager -n vmware-system-tmc -f


k get packageinstall -n tkg-system  prometheus -o yaml

k rollout restart deployment.apps/prometheus-server -n tanzu-system-monitoring

k get deployment.apps/prometheus-server -n tanzu-system-monitoring -o yaml 

k logs deployment.apps/prometheus-server -n tanzu-system-monitoring --all-containers -f

k get all -n tanzu-system-monitoring

tanzu package installed kick -n tkg-system prometheus -y


tanzu package installed delete prometheus --namespace tkg-system 

k port-forward service/prometheus-server 8080:80 -n tanzu-system-monitoring



## 
[prometheus-node-exporter] Liveness probe fails with http status code 401 when configured with http basic auth
https://github.com/prometheus-community/helm-charts/issues/3688
