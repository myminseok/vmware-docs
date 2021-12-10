#!/bin/bash

for image in `cat docker-images.txt`; do
tarfile=`echo "${image//\//__}.tar"`
echo "importing $tarfile $image"
if [ -f "$tarfile.gz" ]; then
 gzip -d $tarfile.gz
fi

docker load -i $tarfile
echo ""
done;
