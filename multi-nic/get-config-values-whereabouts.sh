tanzu package repository add tce-repo --url projects.registry.vmware.com/tce/main:0.10.0 --namespace tanzu-package-repo-global
tanzu package available list whereabouts.community.tanzu.vmware.com -A
tanzu package available get whereabouts.community.tanzu.vmware.com/0.5.0 --values-schema -o yaml > whereabouts-value-schama.yml

kubectl -n tanzu-package-repo-global get packages
image_url=$(kubectl -n tanzu-package-repo-global get packages  whereabouts.community.tanzu.vmware.com.0.5.0 -o jsonpath='{.spec.template.spec.fetch[0].imgpkgBundle.image}')
imgpkg pull -b $image_url -o ./whereabouts
