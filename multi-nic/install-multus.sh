tanzu package install multus-cni \
	--package-name multus-cni.tanzu.vmware.com \
	--version 3.7.1+vmware.2-tkg.2 \
	--values-file multus-cni-values.yaml

tanzu package installed get multus-cni
