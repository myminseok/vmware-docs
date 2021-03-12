kubectl delete -f ./extensions/logging/fluent-bit/fluent-bit-extension.yaml

kubectl delete daemonset.apps/fluent-bit -n tanzu-system-logging

kubectl delete app fluent-bit -n tanzu-system-logging

