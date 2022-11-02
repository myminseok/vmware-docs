kubectl create ns tkg-extensions
tanzu package available list cert-manager.tanzu.vmware.com
tanzu package install cert-manager --package-name cert-manager.tanzu.vmware.com --namespace tkg-extensions --version 1.7.2+vmware.1-tkg.1 --create-namespace

