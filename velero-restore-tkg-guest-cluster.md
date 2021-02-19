### Why
This is for Disaster Recovery with service downtime.
 

**As personaName**
**I want **
**So that **

### Acceptance Criteria

```gherkin
Scenario: 
Given
When
Then
```

**Notes:**


# pre-requisite

-  install velero to target cluster



## set velero readonly (backupstoragelocation)
```
k patch backupstoragelocation default -n velero --type merge  --patch '{"spec":{"accessMode":"ReadOnly"}}'

k get backupstoragelocation  -n velero
NAME      PHASE       LAST VALIDATED   AGE
default   Available   42s              21m
```

## wait for backup sync
you can see backup list . default sync interval  from minio is 1 min
```
ubuntu@ubuntu-455:~$ velero backup get
NAME             STATUS            ERRORS   WARNINGS   CREATED                         EXPIRES   STORAGE LOCATION   SELECTOR
default-backup   PartiallyFailed   1        0          2021-02-15 08:06:01 -0800 PST   29d       default            <none>
```

# #restore backup 
```
velero restore create --from-backup BACKUP-NAME  

# --include-namespaces yelb (optional)
```

## check  restore 
velero namespace를 제외한 것 복구완료
```
ubuntu@ubuntu-455:~$ velero restore get
NAME                        BACKUP       STATUS      STARTED                         COMPLETED                       ERRORS   WARNINGS   CREATED                         SELECTOR
ns1-tkg1-1-20210217032109   ns1-tkg1-1   Completed   2021-02-17 03:21:09 -0800 PST   2021-02-17 03:22:02 -0800 PST   0        60         2021-02-17 03:21:09 -0800 PST   <none>
```

```
$ velero backup describe ns1-tkg1 --details
Restic Backups:
  Completed:
    velero/restic-2kk2v: scratch
    velero/restic-ltgf2: scratch
    velero/restic-w4nwk: scratch
    velero/velero-7855bbfc66-gc8h9: plugins, scratch
  New:
    vmware-system-cloud-provider/guest-cluster-cloud-provider-8995d766b-wqcxn: ccm-config, ccm-owner-reference, ccm-provider
Phase:  Completed
```


# check pv store
ssh into redis-server pod and check volume.

```
ubuntu@ubuntu-455:~/workspace/velero$ k get all -n yelb
NAME                                  READY   STATUS    RESTARTS   AGE
pod/redis-server-7b5974687c-xvx28     1/1     Running   0          84m
pod/yelb-appserver-7794b7c885-t2r2g   1/1     Running   0          84m
pod/yelb-db-5d9b667cc8-zbmlf          1/1     Running   0          84m
pod/yelb-ui-65c84ff544-lk7f4          1/1     Running   3          84m
pod/yelb-ui-65c84ff544-npl2z          1/1     Running   3          84m

NAME                     TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)        AGE
service/redis-server     ClusterIP      10.106.152.117   <none>          6379/TCP       83m
service/yelb-appserver   ClusterIP      10.104.180.14    <none>          4567/TCP       83m
service/yelb-db          ClusterIP      10.104.49.133    <none>          5432/TCP       83m
service/yelb-ui          LoadBalancer   10.102.255.172   10.213.227.67   80:31278/TCP   83m

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-server     1/1     1            1           84m
deployment.apps/yelb-appserver   1/1     1            1           84m
deployment.apps/yelb-db          1/1     1            1           84m
deployment.apps/yelb-ui          2/2     2            2           84m

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/redis-server-644c67b79d     0         0         0       84m
replicaset.apps/redis-server-7b5974687c     1         1         1       84m
replicaset.apps/yelb-appserver-7794b7c885   1         1         1       84m
replicaset.apps/yelb-appserver-78599976f4   0         0         0       84m
replicaset.apps/yelb-db-5d9b667cc8          1         1         1       84m
replicaset.apps/yelb-db-84c6745fb9          0         0         0       84m
replicaset.apps/yelb-ui-65c84ff544          2         2         2       84m
ubuntu@ubuntu-455:~/workspace/velero$ ssh ^C
ubuntu@ubuntu-455:~/workspace/velero$ k exec -it pod/redis-server-7b5974687c-xvx28 -n yelb bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl kubectl exec [POD] -- [COMMAND] instead.
root@redis-server-7b5974687c-xvx28:/
```
