https://linuxize.com/post/how-to-configure-static-ip-address-on-ubuntu-20-04/


## static ip
get device name
```sh
ip addr
```


```sh
ls -al /etc/netplan
```
```sh
mv /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.orig
```

```sh
vi /etc/netplan/50-cloud-init.yaml

# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        id0:
            dhcp4: false    <=== disable this
            dhcp6: false
            match:
                macaddress: 00:50:56:9d:84:fe
            set-name: eth0
            wakeonlan: true
    version: 2
```
    

```sh
cat > /etc/netplan/01-netcfg.yaml << "EOF"
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.0.102/16
      gateway4: 192.168.0.1
      nameservers:
          addresses: [192.168.0.5]
```
> change eth device name


```sh
sudo netplan apply
ip addr
```


```
