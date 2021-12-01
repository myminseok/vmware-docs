## cat generate-self-signed-cert/openssl-domain.conf
#[ alt_names ]
#DNS.1 = kubeflow.mvp.bsl.local
#IP.1   = 127.0.0.1
#IP.3 = 10.200.159.52

kubectl delete secret nginx-tls
kubectl create secret tls nginx-tls --cert=./generate-self-signed-cert/domain.crt --key=./generate-self-signed-cert//domain.key  
