#!/bin/bash
#set -ex

#export sourcefile="tkc-kmin-control-plane-simple.yml"
export sourcefile="tkc-kmin-control-plane-long.yml"

## finding target content index
export INDEX=$(ytt -f $sourcefile -o json | jq '.spec.kubeadmConfigSpec.files | to_entries | .[] | select ( .value.content != null) | select(.value.content | contains("EncryptionConfiguration")).key')

echo "[debug] 'EncryptionConfiguration' found at content[$INDEX]"
echo ""
cat > values.yml <<EOF
#@data/values
---
content_index: $INDEX
EOF


# # extracting target content index
# ytt -f $sourcefile -o json | jq '.spec.kubeadmConfigSpec.files | to_entries | .[] | select ( .value.content != null) | select(.value.content | contains("EncryptionConfiguration")).value.content' | tr -d '"'> content-existing.yml.tmp
# printf -- "$(cat content-existing.yml.tmp)" > content-existing.yml


ytt -f $sourcefile -f ytt-replace-content.yml -f values.yml  > $sourcefile-modified.yml
rm -rf values.yml

echo "[debug]"
cat $sourcefile-modified.yml | grep -A 20 "EncryptionConfiguration"
