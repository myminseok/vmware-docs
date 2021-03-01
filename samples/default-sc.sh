kubectl patch storageclass pacific-gold-storage-policy -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

