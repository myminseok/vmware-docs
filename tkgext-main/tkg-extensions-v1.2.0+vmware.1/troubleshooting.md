
# delete hang;  'terminating' namespace forcefully
it happens sometimes when deleting extensions.
```
kubectl delete -f ./extensions/monitoring/prometheus/prometheus-extension.yaml

kubectl delete app prometheus -n tanzu-system-monitoring
```

solution:
find  all  `pending` resources. and delete forcefully.

```

kubectl get all -n tanzu-system-monitoring 
kubectl get pvc -n tanzu-system-monitoring 

kubectl delete service/prometheus -n tanzu-system-monitoring
kubectl delete deployment.apps/prometheus-server -n tanzu-system-monitoring
kubectl delete deployment.apps/prometheus-alertmanager -n tanzu-system-monitoring

```




# delete hang;  'terminating' namespace forcefully
it happens sometimes when deleting namespace.
```
kubectl get ns
NAME                                 STATUS        AGE
default                              Active        2d11h
kube-node-lease                      Active        2d11h
kube-public                          Active        2d11h
kube-system                          Active        2d11h
tanzu-system-logging                 Terminating   13m
```

```
 kubectl api-resources --verbs=list --namespaced -o name \
>   | xargs -n 1 kubectl get --show-kind --ignore-not-found -n  tanzu-system-logging

NAME                              DESCRIPTION                                                                                                   SINCE-DEPLOY   AGE
app.kappctrl.k14s.io/fluent-bit   Delete failed: Preparing kapp: Getting service account: serviceaccounts "fluent-bit-extension-sa" not found   4s             29m
```

Need to remove the finalizer for kubernetes.

```
Step 1:
kubectl get namespace <YOUR_NAMESPACE> -o json > <YOUR_NAMESPACE>.json
kubectl get ns tanzu-system-logging -o json > tanzu-system-logging.json

Step 2: remove kubernetes from finalizers array which is under spec

Step 3:
kubectl replace --raw "/api/v1/namespaces/<YOUR_NAMESPACE>/finalize" -f ./<YOUR_NAMESPACE>.json
kubectl replace --raw "/api/v1/namespaces/tanzu-system-logging/finalize" -f ./tanzu-system-logging.json

You can see that the annoying namespace is gone.
kubectl get namespace

```


# delete clusterrolebinding and clusterrole
```

kubectl get clusterrolebinding| grep prometheus  | awk '{print $1}' > list
while read -r line;do yes| kubectl delete clusterrolebinding $line; done < list


kubectl get clusterrole | grep prometheus  | awk '{print $1}' > list
while read -r line;do yes| kubectl delete clusterrole $line; done < list

```


# patch default sc
```
kubectl patch storageclass pacific-gold-storage-policy -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

