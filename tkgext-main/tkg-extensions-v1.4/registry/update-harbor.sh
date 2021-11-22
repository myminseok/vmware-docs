yq -i eval '... comments=""' harbor-data-values.yaml
tanzu package installed update harbor \
	--package-name harbor.tanzu.vmware.com \
	--version 2.2.3+vmware.1-tkg.1 \
	--values-file harbor-data-values.yaml \
	--namespace tkg-extensions 
