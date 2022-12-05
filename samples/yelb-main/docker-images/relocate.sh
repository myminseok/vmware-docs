#!/bin/bash
set -ex;
for image_url in `cat docker-images.txt`; do
    image=$(echo $image_url | rev| cut -d'/' -f1 | rev | cut -d':' -f1 )
    imgpkg copy -i $image_url --to-repo infra-harbor2.lab.pcfdemo.net/library/$image
done;

