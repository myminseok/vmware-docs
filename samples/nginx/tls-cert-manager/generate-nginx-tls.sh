kubectl apply -f self-signed-issuer.yml
kubectl apply -f self-signed-certs-lab-pcfdemo.net.yml
kubectl get secret nginx-tls -o yaml -o jsonpath='{.data.tls\.crt}' | base64 -d > nginx-tls.crt
