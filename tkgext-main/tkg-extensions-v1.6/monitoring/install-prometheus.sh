tanzu package available list prometheus.tanzu.vmware.com

tanzu package install prometheus \
--package-name prometheus.tanzu.vmware.com  \
--version 2.27.0+vmware.2-tkg.1 \
--namespace tkg-extensions --create-namespace
