tanzu package available list contour.tanzu.vmware.com
#1.17.2+vmware.1-tkg.2
tanzu package install contour \
--package-name contour.tanzu.vmware.com \
--version 1.17.2+vmware.1-tkg.2 \
--values-file contour-data-values-vsphere.yaml \
--namespace tkg-extensions --create-namespace
