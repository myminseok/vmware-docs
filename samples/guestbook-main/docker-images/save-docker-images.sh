#!/bin/bash

for image in `cat docker-images.txt`; do
echo "pull $image"
docker pull $image
tarfile=`echo "${image//\//__}.tar"`
echo "saving $image to $tarfile"
docker save -o $tarfile $image
#gzip $tarfile
echo ""
done;
