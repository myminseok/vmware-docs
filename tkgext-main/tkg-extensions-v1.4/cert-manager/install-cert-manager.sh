kubectl create ns tkg-extensions
tanzu package available list cert-manager.tanzu.vmware.com
#tanzu package install cert-manager --package-name cert-manager.tanzu.vmware.com --namespace tkg-extensions --version 1.1.0+vmware.1-tkg.2 --create-namespace
tanzu package install cert-manager --package-name cert-manager.tanzu.vmware.com --namespace tkg-extensions --version 1.1.0+vmware.2-tkg.1 --create-namespace

