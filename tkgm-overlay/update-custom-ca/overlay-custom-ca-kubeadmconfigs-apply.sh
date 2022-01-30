#!/bin/bash
set -e

## after applying this, control plane will be recteated automatically
kubectl get kubeadmconfig | grep -v "NAME" | awk '{print $1}'> tmp_nodes.txt
while IFS= read -r node; do
 echo "$node"
 kubectl get kubeadmconfig $node -o yaml | ytt  -f overlay-custom-ca-kubeadmconfigs-upsert.yml -f ./tkg-custom-ca.pem  -f - | kubectl replace -f -
done < tmp_nodes.txt
rm -f tmp_nodes.txt

## recreate worker node.
kubectl patch md tkc-noavi-md-0 --type merge --patch "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"date\":\"`date +'%s'`\"}}}}}"
