https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/2.3/using-tkg/workload-packages-contour.html

tanzu package repository list -A 

tanzu package repository delete -n tkg-system tanzu-standard 

tanzu package repository add tanzu-standard --url projects.registry.vmware.com/tkg/packages/standard/repo:v2023.7.13 -n tkg-system

tanzu package available list -A  

tanzu package available get -n tkg-system  contour.tanzu.vmware.com


NAME:                   contour.tanzu.vmware.com
DISPLAY-NAME:           contour
CATEGORIES:             - ingress
- envoy
- contour
SHORT-DESCRIPTION:      An ingress controller
LONG-DESCRIPTION:       An Envoy-based ingress controller that supports dynamic configuration updates
and multi-team ingress delegation. See https://projectcontour.io for more
information.
PROVIDER:               VMware
MAINTAINERS:            - name: Steve Kriss
- name: Sunjay Bhatia
SUPPORT-DESCRIPTION:    Support provided by VMware for deployment on Tanzu clusters. Best-effort support
for deployment on any conformant Kubernetes cluster. Contact support by opening
a support request via VMware Cloud Services or my.vmware.com.

  VERSION                RELEASED-AT                    
  1.24.5+vmware.1-tkg.1  2023-07-26 09:00:00 +0900 KST  



tanzu package available get -n tkg-system  contour.tanzu.vmware.com/1.24.4+vmware.1-tkg.1 --values-schema




tanzu package installed delete -n tkg-system contour   
tanzu package install contour --package contour.tanzu.vmware.com --version 1.24.4+vmware.1-tkg.1  --values-file contour-data-values.yaml --namespace tkg-system

