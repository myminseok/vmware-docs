#!/bin/bash
set -x
#ls -al ~/.config/tanzu/tkg/providers/ytt/03_customizations/01_tkr/
#cp ./etc-hosts-vsphere-overlay.yml ~/.config/tanzu/tkg/providers/infrastructure-vsphere/ytt/vsphere-overlay.yaml
#cp ./etc-hosts-tkr_overlay.lib.yml ~/.config/tanzu/tkg/providers/ytt/03_customizations/01_tkr/tkr_overlay.lib.yaml 

cp ./ntp-vsphere-overlay.yml ~/.config/tanzu/tkg/providers/infrastructure-vsphere/ytt/
cp ./vsphere-overlay-dns-control-plane.yaml ~/.config/tanzu/tkg/providers/infrastructure-vsphere/ytt/
cp ./vsphere-overlay-dns-workers.yaml ~/.config/tanzu/tkg/providers/infrastructure-vsphere/ytt/
cp ./tkg-custom-ca.* ~/.config/tanzu/tkg/providers/infrastructure-vsphere/ytt/
ls -al  ~/.config/tanzu/tkg/providers/infrastructure-vsphere/ytt/
