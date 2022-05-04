# tanzu package repository add tce-repo --url projects.registry.vmware.com/tce/main:0.10.0 --namespace tanzu-package-repo-global
# tanzu package available list whereabouts.community.tanzu.vmware.com -A
# tanzu package available get whereabouts.community.tanzu.vmware.com/0.5.0 --values-schema -o yaml
tanzu package install whereabout \
	--package-name   whereabouts.community.tanzu.vmware.com \
	--version 0.5.0 

tanzu package installed get whereabout
