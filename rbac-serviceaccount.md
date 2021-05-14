# external access using service account.

## create a service account

```
kubectl create serviceaccount custom-sa -n default
```


## cluster rolebinding to service account

```
kubectl create clusterrole custom-role \
--verb=get,list,watch,create,delete \
--resource="*"
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: custom-role
rules:
- apiGroups:
  - ""
  resources:
  - '*'
  verbs:
  - get
  - list
  - watch
  - create
  - delete

```

```
kubectl create clusterrolebinding custom-binding \
--clusterrole=custom-role  \
--serviceaccount=default:custom-sa
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:  
  name: custom-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: custom-role
subjects:
- kind: ServiceAccount
  name: custom-sa
  namespace: default
```


## accessing via curl
```
kubectl get secret
NAME                    TYPE                                  DATA   AGE
custom-sa-token-dblzv   kubernetes.io/service-account-token   3      9m1s
default-token-lpnrt     kubernetes.io/service-account-token   3      19d


export TOKEN=$(kubectl get secret custom-sa-token-dblzv -o jsonpath={.data.token} | base64 -d)

curl -k -H "Authorization: Bearer $TOKEN" https://10.90.12.133:6443/api/v1/namespaces

```



## accessing via kubectl
```
kubectl get secret
NAME                    TYPE                                  DATA   AGE
custom-sa-token-dblzv   kubernetes.io/service-account-token   3      9m1s
default-token-lpnrt     kubernetes.io/service-account-token   3      19d



kubectl config set-credentials custom-sa --token=$(kubectl get secret custom-sa-token-dblzv -o jsonpath={.data.token} | base64 -d)


kubectl config set-cluster custom-cluster --server=https://10.90.12.133:6443 --insecure-skip-tls-verify=true
Cluster "custom-cluster" set.


kubectl config get-clusters
NAME
10.90.12.133
custom-cluster
supervisor-10.90.12.129


kubectl config set-context custom-sa-context --user=custom-sa --cluster=custom-cluster


kubectl config get-contexts
CURRENT   NAME                       CLUSTER        AUTHINFO                                          NAMESPACE
          custom-sa-context          custom-cluster   custom-sa


kubectl config use-context custom-sa-context


kubectl get nodes
NAME                                      STATUS   ROLES    AGE   VERSION
tkc-kmin-control-plane-nbt66              Ready    master   19d   v1.19.7+vmware.1
tkc-kmin-workers-rw2qn-669686bdf4-4hkkr   Ready    <none>   45h   v1.19.7+vmware.1
tkc-kmin-workers-rw2qn-669686bdf4-zwxlj   Ready    <none>   19d   v1.19.7+vmware.1


```
