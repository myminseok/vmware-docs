https://projectcontour.io/docs/v1.20.2/configuration/

kubectl get secret contour-tkg-extensions-values -n tkg-extensions -o yaml -ojsonpath='{.data.contour-data-values-vsphere\.yaml}' | base64 -d
