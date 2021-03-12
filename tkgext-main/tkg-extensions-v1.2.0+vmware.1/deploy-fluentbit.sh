kubectl apply -f ./extensions/logging/fluent-bit/namespace-role.yaml
kubectl create secret generic fluent-bit-data-values --from-file=values.yaml=./extensions/logging/fluent-bit/elasticsearch/fluent-bit-data-values.yaml -n tanzu-system-logging -o yaml --dry-run | kubectl replace -f-
kubectl apply -f ./extensions/logging/fluent-bit/fluent-bit-extension.yaml
