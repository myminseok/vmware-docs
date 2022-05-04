kubeseal  --controller-name=sealed-secrets-controller  --controller-namespace=kube-system  --fetch-cert 
kubeseal  --fetch-cert 
echo -n bar | kubectl create secret generic mysecret --dry-run=client --from-file=foo=/dev/stdin -o json >mysecret.json
kubeseal < mysecret.json > mysealedsecret.json
kubectl delete sealedsecret mysecret
kubectl create -f mysealedsecret.json
kubectl get sealedsecret 
kubectl get secret mysecret

echo "kubectl delete secret mysecret"
