#helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm install my-sealed -f ./sealed-secrets/values.yaml sealed-secrets/sealed-secrets -n kube-system
