# for root.crt
openssl genrsa -out root.key 2048
yes "" | openssl req -new -key root.key -config openssl-root.conf -out root.csr
openssl x509 -sha256 -req -days 3650 -set_serial 1 -in root.csr -signkey root.key -out root.crt -extfile openssl-root.conf 


#for domain.key, domain.csr
openssl genrsa -out domain.key 2048
yes "" | openssl req -new -key domain.key -config openssl-domain.conf -out domain.csr
openssl req -text -noout -verify -in domain.csr

# for domain.crt
openssl x509 -sha256 -req -days 3650 -extensions v3_user -in domain.csr -CA root.crt -CAcreateserial -CAkey root.key -out domain.crt -extfile openssl-domain.conf
openssl x509 -text -in domain.crt

cat  domain.crt root.crt> bundle.crt
