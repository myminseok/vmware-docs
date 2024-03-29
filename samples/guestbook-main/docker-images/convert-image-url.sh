#!/bin/bash

set -ex

## required: define source file folder to work
SOURCE_ABS=$( cd ../guestbook/  && pwd )

TARGET_FOLDER="${SOURCE_ABS}-converted"
TARGET_URL="harbor.h2o-2-2257.h2o.vmware.com\/library"
rm -rf $TARGET_FOLDER
cp -r $SOURCE_ABS $TARGET_FOLDER

## detect remote os.
OS=$(uname)



while read -r image_url; do
  image=$(echo $image_url | rev| cut -d'/' -f1 | rev )
  image_url_encoded=$(echo $image_url | sed  's/\//\\\//g'  )
  if [ "$OS" == "Darwin" ]; then
    command="find $TARGET_FOLDER -maxdepth 1 -type f  | xargs  sed -i '' 's/$image_url_encoded/$TARGET_URL\/$image/g' "
  else
    command="find $TARGET_FOLDER -maxdepth 1 -type f  | xargs  sed -i    's/$image_url_encoded/$TARGET_URL\/$image/g' "
  fi
  eval $command 
done < docker-images.txt
