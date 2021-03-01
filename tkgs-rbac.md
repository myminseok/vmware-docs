
# Binding vcenter sso user to TKC 


## create devops-user1 on vcenter namespace ns1
- permission: devops-admin1@vsphere.local /EDIT
- permission: devops-user1@vsphere.local / VIEW


## set role,rolebinding on TKC 

login TKC mycluster as administrator
```
kubectl vsphere login --insecure-skip-tls-verify \
--server=wcp.haas-455.pez.vmware.com \
--tanzu-kubernetes-cluster-namespace ns1 \
--tanzu-kubernetes-cluster-name ns1-tkg1  \
--vsphere-username administrator@vsphere.local


kubectl create namespace org1

cat > custom-space-edit-role.yml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: custom-space-edit-role
  namespace: org1
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
EOF


cat > custom-space-rolebinding.yml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: custom-space-rolebinding
  namespace: org1
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: custom-space-edit-role
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: sso:devops-user1@vsphere.local
EOF


k apply -f custom-space-edit-role.yml


k get role -n org1
NAME                     CREATED AT
custom-space-edit-role   2021-02-26T10:02:21Z



k apply -f custom-space-rolebinding.yml

k get rolebinding -n org1
NAME                       ROLE                          AGE
custom-space-rolebinding   Role/custom-space-edit-role   12s

```


login TKC mycluster as devops-user1
```
kubectl vsphere login --insecure-skip-tls-verify \
--server=wcp.haas-455.pez.vmware.com \
--tanzu-kubernetes-cluster-namespace ns1 \
--tanzu-kubernetes-cluster-name ns1-tkg1  \
--vsphere-username devops-user1@vsphere.local


ubuntu@ubuntu-455:~/workspace/rbac$ k get nodes
Error from server (Forbidden): nodes is forbidden: User "sso:user1@vsphere.local" cannot list resource "nodes" in API group "" at the cluster scope


ubuntu@ubuntu-455:~/workspace/rbac$ k get pod -n org1
NAME                         READY   STATUS             RESTARTS   AGE
nginx-app2-99b5db6c8-lsz7d   0/1     ImagePullBackOff   0          14m

```

