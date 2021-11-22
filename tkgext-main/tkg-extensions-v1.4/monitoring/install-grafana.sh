tanzu package install grafana \
	--package-name grafana.tanzu.vmware.com \
	--version 7.5.7+vmware.1-tkg.1 \
	--values-file grafana-data-values.yaml \
	--namespace tkg-extensions \
	--create-namespace
