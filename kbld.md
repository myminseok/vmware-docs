
# docker image upload test
https://docs.pivotal.io/tas-kubernetes/0-7/configuring-sys-image-registry.html



## kbld pkg

```
grep -r "image: " . | awk '{print $2" "$3}' | grep "^image" | sed  's/,//g'  | sort | uniq | grep -v '(' | grep  -v "'" > kbld_1_images


echo "images:" > kbld_2_manifest.yml
while read -r line; do echo "- $line" >> kbld_2_manifest.yml ; done <kbld_1_images



cat kbld_2_manifest.yml
images:
- image: mreferre/yelb-appserver:0.5
- image: mreferre/yelb-db:0.5
- image: mreferre/yelb-ui:0.7
- image: redis:4.0.2


$ kbld version
kbld version 0.29.0

kbld  -f ./kbld_2_manifest.yml > kbld_3_manifest_resolved.yml



kbld  pkg -f ./kbld_3_manifest_resolved.yml  --output ./kbld_packaged_images.tar
```

## kbld unpkg


```
docker login https://core.harbor.domain -u admin -p 


kbld unpkg -f ./kbld_3_manifest_resolved.yml --input ./kbld_packaged_images.tar --repository core.harbor.domain/ns1/app --lock-output ./kbld_3_manifest_resolved.lock  --registry-verify-certs=false

kbld unpkg -f ./kbld_3_manifest_resolved.yml --input ./kbld_packaged_images.tar --repository 10.213.227.68/ns1/app --lock-output ./kbld_3_manifest_resolved.lock  --registry-verify-certs=false
unpackage | importing 4 images...
unpackage | importing index.docker.io/mreferre/yelb-appserver@sha256:db367946dc02cf38752ad925e0b0fbff0f5c6f9186ca481fb8541530879d9c8d -> 10.213.227.68/ns1/app@sha256:db367946dc02cf38752ad925e0b0fbff0f5c6f9186ca481fb8541530879d9c8d...
unpackage | importing index.docker.io/mreferre/yelb-ui@sha256:a2199d4f9fd38b168af93acf25331cda4e93140704bcba585d8981e0eeec0050 -> 10.213.227.68/ns1/app@sha256:a2199d4f9fd38b168af93acf25331cda4e93140704bcba585d8981e0eeec0050...
unpackage | importing index.docker.io/library/redis@sha256:cd277716dbff2c0211c8366687d275d2b53112fecbf9d6c86e9853edb0900956 -> 10.213.227.68/ns1/app@sha256:cd277716dbff2c0211c8366687d275d2b53112fecbf9d6c86e9853edb0900956...
unpackage | importing index.docker.io/mreferre/yelb-db@sha256:6412d2fe96ee71ca701932d47675c549fe0428dede6a7975d39d9a581dc46c0c -> 10.213.227.68/ns1/app@sha256:6412d2fe96ee71ca701932d47675c549fe0428dede6a7975d39d9a581dc46c0c...
```