NS=nginx-test
kubectl get secret nginx-tls -o yaml -o jsonpath='{.data.tls\.crt}' -n $NS | base64 -d > nginx-tls.crt
