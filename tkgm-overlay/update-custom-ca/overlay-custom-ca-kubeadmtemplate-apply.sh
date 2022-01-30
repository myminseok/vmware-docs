#!/bin/bash
set -ex
kubectl get KubeadmControlPlane  tkc-noavi-control-plane -o yaml >tkc-noavi-control-plane.yml
kubectl get KubeadmConfigTemplate  tkc-noavi-md-0 -o yaml > tkc-noavi-md-0.yml
kubectl get KubeadmControlPlane  tkc-noavi-control-plane -o yaml | ytt -f  ./overlay-custom-ca-kubeadmtemplate-upsert.yml -f tkg-custom-ca.pem -f - | kubectl replace -f -
kubectl get KubeadmConfigTemplate  tkc-noavi-md-0 -o yaml | ytt -f  ./overlay-custom-ca-kubeadmtemplate-upsert.yml -f tkg-custom-ca.pem -f - | kubectl replace -f -

