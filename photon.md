

https://vmware.github.io/photon/assets/files/html/3.0/photon_admin/setting-a-static-ip-address.html

## static ip
```

networkctl

IDX LINK             TYPE               OPERATIONAL SETUP
  1 lo               loopback           carrier     unmanaged
  2 eth0             ether              routable    configured



ls -al /etc/systemd/network

total 20
drwxr-xr-x 2 root            root            4096 Sep 17 04:01 .
drwxr-xr-x 6 root            root            4096 Jan 21  2021 ..
-rw-r--r-- 1 systemd-network systemd-network   58 Sep 12 15:30 10-id0.network
-rw-r--r-- 1 root            root              74 Sep 17 04:00 10-static-en.network
-rw-r--r-- 1 root            root              52 Jan 21  2021 99-dhcp-en.network



cat > /etc/systemd/network/10-static-en.network << "EOF"

[Match]
Name=eth0

[Network]
Address=192.168.0.21/24
Gateway=192.168.0.1
EOF

chmod 644 /etc/systemd/network/10-static-en.network

mv /etc/systemd/network/10-id0.network /etc/systemd/network/10-id0.network.orig


systemctl restart systemd-networkd


```
