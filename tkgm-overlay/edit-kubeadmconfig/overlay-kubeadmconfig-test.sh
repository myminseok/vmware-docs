#!/bin/bash
set -ex
ytt -f tkc-noavi-md-0-6589s.orig.yml -f overlay-kubeadmconfig-upsert.yml -f ./tkg-custom-ca.pem
ytt -f tkc-noavi-md-0-6589s-exists.yaml -f overlay-kubeadmconfig-upsert.yml -f ./tkg-custom-ca.pem

# ytt -f ~/.config/tanzu/tkg/providers/infrastructure-vsphere/v0.7.10/ytt/base-template.yaml -f ./tkg-custom-ca.yaml -f tkg-custom-ca.pem=./tkg-custom-ca.pem
