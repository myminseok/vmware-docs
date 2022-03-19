kubectl create secret generic example  --dry-run=client -o yaml --from-literal=foo=foovalue --from-literal=server1=server1Value --from-literal=server2=serve2Value --from-literal=database1=database1Value > example-secert.yml
kubeseal <example-secert.yml  -o yaml > example-sealedsecert.yml
cat sealedsecret.yaml.data >> example-sealedsecert.yml 
