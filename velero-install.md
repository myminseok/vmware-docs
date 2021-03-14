# Backup TKG with velero and restic 
- for Tanzu Kubernetes cluster on TKGs v1.2.1(vsphere7)
- for Guest cluster from TKGm

# velero docs
- https://velero.io/docs/v1.5/how-velero-works/
- https://github.com/vmware-tanzu/velero
- https://velero.io/blog/velero-v1-1-stateful-backup-vsphere
- https://github.com/vmware-tanzu/velero-plugin-for-aws


# Prerequisites 

## Download tkg , tkg extension bundle, velero, cert manager, kubectl
https://www.vmware.com/go/get-tkg

## Download  velero cli
```
wget https://github.com/vmware-tanzu/velero/releases/download/v1.5.3/velero-v1.5.3-linux-amd64.tar.gz
cp velero-v1.5.3-linux-amd64/velero ~/bin/
```

## Prepare minio
install test minio cluster on k8s
- https://github.com/vmware-tanzu/velero/blob/main/examples/minio/00-minio-deployment.yaml

#  Install velero-server
- install: https://velero.io/docs/v1.5/basic-install/

## credentials-velero
```
cat > credentials-velero << EOF
[default]
aws_access_key_id=myaccesskey
aws_secret_access_key=mysecretkey
EOF
```


## Install velero server on k8s
```
velero install \
--provider aws \
--bucket velero \
--secret-file ./credentials-velero \
--plugins velero/velero-plugin-for-aws:v1.1.0 \
--snapshot-location-config region=minio \
--backup-location-config \
region=minio,s3ForcePathStyle="true",s3Url=http://10.213.227.70:9000,publicUrl=http://10.213.227.70:9000 \
--use-restic \
--default-volumes-to-restic 

```
- it will create velero namespace
- --secret-file ./credentials-velero 

## Install velero server on k8s (from private registry)
```
velero install \
--provider aws \
--bucket velero \
--secret-file ./credentials-velero \
--plugins PRIVATE-REGISTRY/velero/velero-plugin-for-aws:v1.1.0 \
--snapshot-location-config region=minio \
--backup-location-config \
region=minio,s3ForcePathStyle="true",s3Url=http://10.213.227.70:9000,publicUrl=http://10.213.227.70:9000 \
--use-restic \
--default-volumes-to-restic 

```
- PRIVATE-REGISTRY

## modify deployments
[private-registry-modify-deployment](private-registry-modify-deployment.md)

# check installation

## deployments
```
kubectl get all -n velero

```
## check cloud-credentials 
```
kubectl get secret -n velero cloud-credentials -o jsonpath='{.data.cloud}' | base64 -d
[default]
aws_access_key_id = myaccesskey
aws_secret_access_key = mysecretkey
```

## check backup-location
```
velero get backup-location
NAME      PROVIDER   BUCKET/PREFIX   PHASE         LAST VALIDATED                  ACCESS MODE
default   aws        velero          Unavailable   2021-02-15 05:46:43 -0800 PST   ReadWrite
```
```
velero get backup-location default -o yaml
kubectl api-resources | grep backup
```

## check backupstoragelocations
```
kubectl get backupstoragelocations default -n velero -o yaml
```

## check snapshot-location
-  A volume snapshot location is a location in which to store the volume snapshots created for a backup.

```
velero snapshot-location create vsl-vsphere --provider velero.io/vsphere
velero get snapshot-location
NAME          PROVIDER
default       aws
vsl-vsphere   velero.io/vsphere

k describe volumesnapshotlocation  vsl-vsphere -n velero

k delete volumesnapshotlocation  vsl-vsphere -n velero
```

## check velero plugin
```
ubuntu@ubuntu-455:~/vsphere-k8s-scripts$ velero plugin get 
NAME                                 KIND
velero.io/crd-remap-version          BackupItemAction
velero.io/pod                        BackupItemAction
velero.io/pv                         BackupItemAction
velero.io/service-account            BackupItemAction
velero.io/aws                        ObjectStore
velero.io/add-pv-from-pvc            RestoreItemAction
velero.io/add-pvc-from-pod           RestoreItemAction
velero.io/change-pvc-node-selector   RestoreItemAction
velero.io/change-storage-class       RestoreItemAction
velero.io/cluster-role-bindings      RestoreItemAction
velero.io/crd-preserve-fields        RestoreItemAction
velero.io/init-restore-hook          RestoreItemAction
velero.io/job                        RestoreItemAction
velero.io/pod                        RestoreItemAction
velero.io/restic                     RestoreItemAction
velero.io/role-bindings              RestoreItemAction
velero.io/service                    RestoreItemAction
velero.io/service-account            RestoreItemAction
velero.io/aws                        VolumeSnapshotter

```


## debug velero deployment
https://velero.io/docs/v1.5/troubleshooting/

```
kubectl edit deployment/velero -n velero
...
   containers:
     - name: velero
       image: velero/velero:latest
       command:
         - /velero
       args:
         - server
         - --log-level # Add this line
         - debug       # Add this line
```



# Uninstalling velero server
- https://velero.io/docs/v1.5/uninstalling/

## login to guest-cluster as admin

## delete velero server
```
kubectl delete namespace/velero clusterrolebinding/velero
kubectl delete crds -l component=velero
```

