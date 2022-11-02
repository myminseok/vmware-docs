yq  eval '... comments=""' harbor-data-values.yaml > harbor-data-values.yaml.nocomment
tanzu package installed update harbor \
	--package-name harbor.tanzu.vmware.com \
	--version 2.2.3+vmware.1-tkg.1 \
	--values-file harbor-data-values.yaml.nocomment \
	--namespace tkg-extensions 
