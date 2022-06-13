kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "embeded-harbor"}]}'
#kubectl replace sa default -f default-sa-harbor.yml
