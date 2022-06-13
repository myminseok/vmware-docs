#!/bin/bash

#image_url=$(kubectl -n tanzu-package-repo-global get packages harbor.tanzu.vmware.com.2.2.3+vmware.1-tkg.1 -o jsonpath='{.spec.template.spec.fetch[0].imgpkgBundle.image}')
#imgpkg pull -b $image_url -o /tmp/harbor-package-2.2.3

ytt --ignore-unknown-comments \
  -f /tmp/harbor-package-2.2.3/config/_ytt_lib/bundle/config \
  -f harbor-data-values.yaml \
  -f fix-fsgroup-overlay.yml
