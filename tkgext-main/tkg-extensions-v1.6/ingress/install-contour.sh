tanzu package available list contour.tanzu.vmware.com
tanzu package install contour \
--package-name contour.tanzu.vmware.com \
--version 1.20.2+vmware.1-tkg.1 \
--values-file contour-data-values-vsphere-custom.yaml \
--namespace tkg-extensions --create-namespace
