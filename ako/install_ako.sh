#helm repo add ako https://projects.registry.vmware.com/chartrepo/ako
# helm show values ako/ako --version 1.4.2 > values.yaml

kubectl create ns avi-system
# projects.registry.vmware.com/ako/ako:1.4.2
helm install ako/ako --generate-name --version 1.4.2 -f values.yaml --set ControllerSettings.controllerIP=avi.lab.pcfdemo.net --set avicredentials.username=admin --set avicredentials.password=VMware123!@# --namespace=avi-system
