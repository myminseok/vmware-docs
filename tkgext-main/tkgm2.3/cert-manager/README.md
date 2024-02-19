

tanzu package repository add tanzu-standard --url projects.registry.vmware.com/tkg/packages/standard/repo:v2023.10.16 -n tkg-system


tanzu package available get   -n tkg-system  cert-manager.tanzu.vmware.com

NAME:                   cert-manager.tanzu.vmware.com
DISPLAY-NAME:           cert-manager
CATEGORIES:             - certificate management
SHORT-DESCRIPTION:      Certificate management
LONG-DESCRIPTION:       Provides certificate management provisioning within the cluster
PROVIDER:               VMware
MAINTAINERS:            - name: Nicholas Seemiller
SUPPORT-DESCRIPTION:    Support provided by VMware for deployment on Tanzu clusters. Best-effort support
for deployment on any conformant Kubernetes cluster. Contact support by opening
a support request via VMware Cloud Services or my.vmware.com.

  VERSION                RELEASED-AT                    
  1.1.0+vmware.1-tkg.2   2020-11-25 03:00:00 +0900 KST  
  1.1.0+vmware.2-tkg.1   2020-11-25 03:00:00 +0900 KST  
  1.11.1+vmware.1-tkg.1  2023-01-11 21:00:00 +0900 KST  
  1.5.3+vmware.2-tkg.1   2021-08-24 02:22:51 +0900 KST  
  1.5.3+vmware.4-tkg.1   2021-08-24 02:22:51 +0900 KST  
  1.5.3+vmware.7-tkg.1   2021-08-24 02:22:51 +0900 KST  
  1.5.3+vmware.7-tkg.3   2021-08-24 02:22:51 +0900 KST  
  1.7.2+vmware.1-tkg.1   2021-10-29 21:00:00 +0900 KST  
  1.7.2+vmware.3-tkg.1   2021-10-29 21:00:00 +0900 KST  
  1.7.2+vmware.3-tkg.3   2021-10-29 21:00:00 +0900 KST  

  tanzu package install cert-manager --package cert-manager.tanzu.vmware.com --namespace tkg-system --version   1.7.2+vmware.3-tkg.3




tanzu package installed delete cert-manager -n tkg-system