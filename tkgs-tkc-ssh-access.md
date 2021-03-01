
# Get SSH secrets of TKC

```

kubectl vsphere login --server WCP-URL -u administrator@vsphere.local --insecure-skip-tls-verify 

kubectl config use-context VSPHERE-NAMESPACE


kubectl get secret -n ns1 | grep ssh
ns1-tkg1-ssh                    kubernetes.io/ssh-auth                1      2d1h
ns1-tkg1-ssh-password           Opaque                                1      2d1h
ns1-tkg2-ssh                    kubernetes.io/ssh-auth                1      2d2h
ns1-tkg2-ssh-password           Opaque                                1      2d2h


kubectl get secret -n ns1 ns1-tkg1-ssh -o jsonpath='{.data.ssh-privatekey}' | base64 -d > ns1-tkg1-ssh.key

kubectl get secret -n ns1 ns1-tkg1-kubeconfig -o jsonpath='{.data.value}' | base64 -d > ns1-tkg1-kubeconfig

kubectl get secret ns1-tkg1-ssh-password  -o jsonpath='{.data.ssh-passwordkey}' | base64 -d 

# test.
ssh -i ns1-tkg1-ssh.key  vmware-system-user@10.244.1.35

```

