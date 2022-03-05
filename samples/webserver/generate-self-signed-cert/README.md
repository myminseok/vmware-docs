# prepare linux or osx env

# edit template-targetdomain-openssl.conf
```

# SSL 서비스할 domain 명 입력
commonName                      = Common Name (eg, your name or your server's hostname)
commonName_default             = pcfdemo.net
commonName_max                  = 64


# Extension copying option: use with caution.
copy_extensions = copy

[ v3_user ]
# Extensions to add to a certificate request
basicConstraints = CA:FALSE
#authorityKeyIdentifier = keyid,issuer
subjectKeyIdentifier = hash
keyUsage = digitalSignature, keyEncipherment
## SSL 용 확장키 필드
extendedKeyUsage = serverAuth,clientAuth
subjectAltName = @alt_names
[ alt_names ]
DNS.1  = *.pcfdemo.net
DNS.2  = *.apps.pcfdemo.net
DNS.3  = *.system.pcfdemo.net
DNS.4  = *.login.system.pcfdemo.net
DNS.5  = *.uaa.system.pcfdemo.net
DNS.6  = pcfdemo.net
IP.1 = 127.0.0.1

```

# run generate.sh
press enter.


now you have domain.crt, domain.key, root.crt



## reference
https://gist.github.com/patrickcrocker/a9256ecdb758ce85d01d
