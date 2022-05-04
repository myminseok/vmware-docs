# Apply Private CA to TKC nodes

## using script
prepare harbor ca file to apply Private CA to TKC nodes

```
wget https://raw.githubusercontent.com/myminseok/vmware-docs/main/samples/tkg-add-ca-via-sv.sh
wget https://raw.githubusercontent.com/myminseok/vmware-docs/main/samples/tkg-add-ca.sh
chmod +x tkg-ssh-sv-vm.sh

./tkg-add-ca-via-sv.sh --vc_ip pacific-vcsa.haas-455.pez.vmware.com --vc_admin_passowrd secret --vc_admin_user administrator@vsphere.local --vc_root_password secret  --sv_ip wcp.haas-455.pez.vmware.com -c ns1-tkg1 -n  ns1  --ca_file_path ../harbor-root-ca.crt
                            
```

## manaul way

### Get SSH secrets of TKC
- [tkgs-tkc-ssh-access](tkgs-tkc-ssh-access.md)


### Copy registry CA to TKG nodes

list TKC node IPs.

```
export KUBECONFIG=ns1-tkg1-kubeconfig

kubectl get nodes -o wide

kubectl get node  -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}'
```

### Copy the Registry root CA bundle to the TKG node and install it into the system trust bundle by appending it to '/etc/pki/tls/certs/ca-bundle.crt'

```
scp -i cluster-ssh <path to Registry Service CA bundle>  vmware-system-user@<node IP>:/home/vmware-system-user/registry_ca.crt

ssh -i cluster-ssh vware-system-user@10.244.1.4 'sudo bash -c "cat /home/vware-system-user/registry_ca.crt >> /etc/pki/tls/certs/ca-bundle.crt"'

ssh -i cluster-ssh vmware-system-user@<node IP> 'sudo systemctl restart containerd'

```


or
```
cp HARBOR_CA.crt /etc/ssl/certs/HARBOR_CA.crt

```


# Modify deployment 
to use private docker registry 
```
spec:
  template:
    spec:
       imagePullSecrets:
       - name: harbor-registry-secret
      containers:
        image: 10.213.227.68/ns1/velero/velero:v1.5.3
      initContainers:
      - image: 10.213.227.68/ns1/velero/velero-plugin-for-aws:v1.1.0
```


### create harbor secret.
```

kubectl delete secret harbor-registry-secret -n velero


kubectl create secret docker-registry harbor-registry-secret --docker-server=https://myprivate-docker --docker-username=USER --docker-password=PASS --namespace YOUR-NAMESPACE


kubectl create secret docker-registry harbor-registry-secret --docker-server=10.213.227.68 --docker-username=user1@vsphere.local --docker-password=VMware1! -n velero
```

### modify deployment

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


### or apply harbor secret to service account

```
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "harbor-registry-secret"}]}'

```

or

```
kubectl get serviceaccounts default -o yaml > ./sa.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: default
  namespace: default
secrets:
- name: default-token-uudge
imagePullSecrets:
- name: harbor-registry-secret


kubectl replace serviceaccount default -f ./sa.yaml
```

tkg-extensions-v1.3.0+vmware.1/extensions/monitoring/prometheus/namespace-role.yaml
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus-extension-sa
  namespace: tanzu-system-monitoring
imagePullSecrets:
- name: harbor-registry-secret
```

# get embeded harbor admin secret from supervisor cluster

ssh into the supervisor cluster vm.
```
HARBOR_NAMESPACE=$(kubectl get ns | grep registry- | awk '{print $1}')

HARBOR_POD_ID=$(echo $HARBOR_NAMESPACE | sed 's/.*-//')

kubectl -n ${HARBOR_NAMESPACE} get secret "harbor-${HARBOR_POD_ID}-controller-registry" --template={{.data.harborAdminUsername}} | base64 --decode | base64 --decode


kubectl -n ${HARBOR_NAMESPACE} get secret "harbor-${HARBOR_POD_ID}-controller-registry" --template={{.data.harborAdminPassword}} | base64 --decode | base64 --decode



```