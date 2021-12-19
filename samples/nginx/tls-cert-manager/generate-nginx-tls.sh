NS=default
kubectl create ns $NS
kubectl apply -f self-signed-issuer.yml -n $NS
kubectl apply -f self-signed-certs-lab-pcfdemo.net.yml -n $NS
