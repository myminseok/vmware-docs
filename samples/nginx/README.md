

## ingress-to-http.yml
it takes HTTPS connection and terminates TLS and forward to http backend.
1. contour tkg-extension is deployed.
2. check AVI: contour server pools should be created but might be down until ingress is created. (default-<CLUSTER_NAME>--tanzu-system-ingress-envoy--443, default-<CLUSTER_NAME>--tanzu-system-ingress-envoy--80)

3. deploy workload
```
kubectl create secret tls nginx-tls --cert=./domain.crt --key=./domain.key
k apply -f nginx-deploy.yml (service with ClusterIP type)
```
4. check AVI: contour server pools should be created and should not be in red. note that server pool `default-<CLUSTER_NAME>--default-nginx-test.lab.pcfdemo.net-nginx-ingress` might be down but workload access should work
```
curl https://nginx-test.lab.pcfdemo.net -k
```
## httpproxy-to-http.yml
The same as above ingress-to-http.yml, but server pool `default-<CLUSTER_NAME>--default-nginx-test.lab.pcfdemo.net-nginx-ingress` is not created.
```
curl https://nginx-test.lab.pcfdemo.net -k
```

## httpproxy-passthrough.yml
it takes HTTPS connection but does not terminate TLS but forward to https backend. https://projectcontour.io/docs/v1.19.0/config/tls-termination.
- it works ClusterIP, NodePort service type of the backend

