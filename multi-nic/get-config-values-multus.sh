
tanzu package available get multus-cni.tanzu.vmware.com/3.7.1+vmware.2-tkg.2 --values-schema -o yaml > multus-value-schema.yml
image_url=$(kubectl -n tanzu-package-repo-global get packages  multus-cni.tanzu.vmware.com.3.7.1+vmware.2-tkg.2 -o jsonpath='{.spec.template.spec.fetch[0].imgpkgBundle.image}')
imgpkg pull -b $image_url -o ./multus
