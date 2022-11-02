kubectl -n tkg-extensions delete secret harbor-velero-overlay
kubectl -n tkg-extensions create secret generic harbor-velero-overlay -o yaml --dry-run=client --from-file=harbor-velero-overlay.yml | kubectl apply -f -

kubectl -n tkg-extensions annotate packageinstalls harbor ext.packaging.carvel.dev/ytt-paths-from-secret-name.1=harbor-velero-overlay

## you have to delete statefulset to update some metadata other than than 'replicas', 'template', and 'updateStrategy'
## updates to statefulset spec for fields other than 'replicas', 'template', and 'updateStrategy' are forbidden (reason: Invalid)

kubectl delete statefulset --all -n tanzu-system-registry

kubectl delete pod --all -n tanzu-system-registry

kubectl get statefulset.apps/harbor-database -n tanzu-system-registry -o yaml
