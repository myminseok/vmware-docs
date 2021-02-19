# pre-requisite
#176996480


# backup
https://velero.io/docs/v1.5/restic/#restore

## create minio bucket
주의: velero backup  후 minio bucket을 삭제하면 이후 백업이 실파함. 이경우는 velero server를 다시 설치할 것.

```
mc alias set minio http://10.213.227.71:9000  myaccesskey mysecretkey
mc rm minio/velero --recursive --force
mc mb minio/velero/restic/default
mc ls minio/velero -r --summarize
```

## backup procedure
- how backup works: https://velero.io/docs/v1.5/how-velero-works/
- volume backup with restic: https://velero.io/docs/v1.5/restic/#how-backup-and-restore-work-with-restic

```
velero backup create BACKUP-NAME  --exclude-namespaces=velero --include-cluster-resources=true 

--exclude-namespaces=velero :  intentionally excludes velero namespace. sometimes backup  hangs  while backing up.
--include-cluster-resources=true : set to backup cluster-resource (due to --exclude-namespaces)

--volume-snapshot-locations vsl-vsphere : default ( no need add )
--snapshot-volumes : true by default. set to false for  dry-run
--exclude-namespaces=vmware-system-cloud-provider
--ttl :  expire period for retension. format 0h0m0s .default 30 days.
```



## check backup
```
ubuntu@ubuntu-455:~$ velero backup get
NAME             STATUS            ERRORS   WARNINGS   CREATED                         EXPIRES   STORAGE LOCATION   SELECTOR
default-backup   PartiallyFailed   1        0          2021-02-15 08:06:01 -0800 PST   29d       default            <none>
```


## k get podvolumebackups -n velero

```
k get resticrepositories -n velero
NAME                 AGE
yelb-default-qqstf   41m
```


## configure yelb app for private registry
```
k get deployment.apps/yelb-appserver -n yelb -o yaml | sed 's/image: /image: 10.213.227.68\/ns1\//g' | ytt   -f add_imagepullsecrets.yml -f -  | kubectl apply -f -
k get deployment.apps/yelb-db -n yelb -o yaml | sed 's/image: /image: 10.213.227.68\/ns1\//g' | ytt   -f add_imagepullsecrets.yml -f -  | kubectl apply -f -
k get deployment.apps/redis-server  -n yelb -o yaml | sed 's/image: /image: 10.213.227.68\/ns1\//g' | ytt   -f add_imagepullsecrets.yml -f -  | kubectl apply -f -
```


## annotate PV for backup.
- no need to ,  it is now default on velero 1.5.x

```
k annotate deployment.apps/redis-server  backup.velero.io/backup-volumes=redis-data -n yelb
```

## check on minio

```
open http://10.213.227.69:9000
```


## delete all backup at once if need
```
velero backup get | awk '{print $1}' > list
while read -r line;do yes| velero delete backup $line; done < list
```

# troubleshooting

## PartiallyFailed
가끔 이유없이 velero backup이 실패함. 이경우 velero server를 다시 설치할것.
