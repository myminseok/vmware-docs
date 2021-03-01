# Backup  with velero and restic 
- for Tanzu Kubernetes cluster on TKGs v1.2.1(vsphere7)
- for Guest cluster from TKGm

# Pre-requisite
-  [install velero to target cluster](velero-install.md)


# Backup
- https://velero.io/docs/v1.5/restic/#to-back-up
- how backup works: https://velero.io/docs/v1.5/how-velero-works/
- volume backup with restic: https://velero.io/docs/v1.5/restic/#how-backup-and-restore-work-with-restic

## create minio bucket
```
mc alias set minio http://10.213.227.71:9000  myaccesskey mysecretkey
mc rm minio/velero --recursive --force
mc mb minio/velero/restic/default
mc ls minio/velero -r --summarize
```

## Backup procedure
```
velero backup create BACKUP-NAME  --exclude-namespaces=velero --include-cluster-resources=true 

```
- -exclude-namespaces=velero :  intentionally excludes velero namespace. sometimes backup  hangs  while backing up.
- --include-cluster-resources=true : set to backup cluster-resource (due to --exclude-namespaces)
- --volume-snapshot-locations vsl-vsphere : default ( no need add )
- --snapshot-volumes : true by default. set to false for  dry-run
- --exclude-namespaces=vmware-system-cloud-provider
- --ttl :  expire period for retension. format 0h0m0s .default 30 days.


## Check backup
```
ubuntu@ubuntu-455:~$ velero backup get
NAME             STATUS            ERRORS   WARNINGS   CREATED                         EXPIRES   STORAGE LOCATION   SELECTOR
default-backup   PartiallyFailed   1        0          2021-02-15 08:06:01 -0800 PST   29d       default            <none>
```

## check minio

```
open http://10.213.227.69:9000
```

# Troubleshooting

## PartiallyFailed
가끔 이유없이 velero backup이 실패함. 이경우 velero server를 다시 설치할것.


## Annotate PV for backup.
- no need. it is now default from velero 1.5

```
k annotate deployment.apps/redis-server  backup.velero.io/backup-volumes=redis-data -n yelb
```