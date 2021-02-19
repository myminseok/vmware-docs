Velero tested on TKG s v1.2.1 on vsphere7

# velero architecture
- https://velero.io/docs/v1.5/how-velero-works/
- https://github.com/vmware-tanzu/velero


# backup PV plugin
- https://github.com/vmware-tanzu/velero-plugin-for-aws
- https://github.com/vmware-tanzu/velero-plugin-for-vsphere
- https://velero.io/blog/velero-v1-1-stateful-backup-vsphere/ => 실제 설치하지 않음.
- https://github.com/vmware-tanzu/velero-plugin-for-csi => beta




#  install velero
- install: https://velero.io/docs/v1.5/basic-install/

## tkg , tkg extension bundle, velero, cert manager, kubectl
https://www.vmware.com/go/get-tkg


## uninstalling velero server
- https://velero.io/docs/v1.5/uninstalling/
```
1)  login to guest-cluster as admin
2) 
kubectl delete namespace/velero clusterrolebinding/velero
kubectl delete crds -l component=velero
```


## velero cli
wget https://github.com/vmware-tanzu/velero/releases/download/v1.5.3/velero-v1.5.3-linux-amd64.tar.gz
cp velero-v1.5.3-linux-amd64/velero ~/bin/


## credentials-velero
```
cat > credentials-velero << EOF
[default]
aws_access_key_id=myaccesskey
aws_secret_access_key=mysecretkey
EOF
```

## install velero server on k8s
```
velero install \
--provider aws \
--bucket velero \
--secret-file ./credentials-velero \
--plugins velero/velero-plugin-for-aws:v1.1.0 \
--snapshot-location-config region=minio \
--backup-location-config \
region=minio,s3ForcePathStyle="true",s3Url=http://10.213.227.70:9000,publicUrl=http://10.213.227.70:9000 \
--use-restic --default-volumes-to-restic 

# --secret-file ./credentials-velero 
#  will create velero namespace
# --use-restic 
# --default-volumes-to-restic 
```

# configure private docker registry to velero 

## create harbor secret.
```
kubectl delete secret harbor-registry-secret -n velero
kubectl create secret docker-registry harbor-registry-secret --docker-server=10.213.227.68 --docker-username=user1@vsphere.local --docker-password=VMware1! -n velero
```

## deployment.apps/velero -n velero에 반영해야 함.
```
spec:
  template:
    spec:
       imagePullSecrets:
       - name: harbor-registry-secret
      containers:
      containers:
        image: 10.213.227.68/ns1/velero/velero:v1.5.3
      initContainers:
      - image: 10.213.227.68/ns1/velero/velero-plugin-for-aws:v1.1.0
```

## apply to pods by script.

```
cat > add_imagepullsecrets.yml <<EOF
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.all
---
spec:
  template:
    spec:
      #@overlay/match missing_ok=True
      imagePullSecrets:
      #@overlay/match by=overlay.index(0)
      - name: harbor-registry-secret
 
EOF
```

```
k get deployment.apps/velero -n velero -o yaml | sed 's/image: /image: 10.213.227.68\/ns1\//g' | ytt   -f add_imagepullsecrets.yml -f -  | kubectl apply -f -
k get daemonset.apps/restic  -n velero -o yaml | sed 's/image: /image: 10.213.227.68\/ns1\//g' | ytt   -f add_imagepullsecrets.yml -f -  | kubectl apply -f -
```


## check  cloud-credentials 
```
k get secret -n velero cloud-credentials -o jsonpath='{.data.cloud}' | base64 -d
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
k api-resources | grep backup
```

## check backupstoragelocations
```
k get backupstoragelocations default -n velero -o yaml
```

## check snapshot-location
-  A volume snapshot location is a location in which to store the volume snapshots created for a backup.
- 백업할 때 없어도 백업 됨.

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


##  velero-plugin-for-vsphere 
restic을 쓸 경우 velero-plugin-for-vsphere는 설치 안해도 됨.

