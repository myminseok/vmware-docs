#!/bin/bash
set -ex;
for image_url in `cat docker-images.txt`; do
    image=$(echo $image_url | rev| cut -d'/' -f1 | rev | cut -d':' -f1 )
    imgpkg copy -i $image_url --to-repo harbor.h2o-2-2257.h2o.vmware.com/library/$image
done;

