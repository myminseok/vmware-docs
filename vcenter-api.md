

### Get vcenter api token 
```
 echo -n 'administrator@vsphere.local:PASSWORD' |  base64 <-- echo -n -> must be used, or encoding will be done including new line character
 YWRtaW5pc3RyYXRvckB2c3BoZXJlLmxvY2FsOlBBU1NXT1JE
```
```
curl https://VCENTER_URL/api/session -X POST -H "Authorization: Basic YWRtaW5pc3RyYXRvckB2c3BoZXJlLmxvY2FsOlBBU1NXT1JE" -v -k
"cb40d6966154bce92713c537d2c4a848"
export SESSIONID=cb40d6966154bce92713c537d2c4a848
```
https://developer.vmware.com/apis/vsphere-automation/latest/cis/api/session/post/


### list vms
```
curl -X GET 'https://VCENTER_URL/api/vcenter/vm' -H 'vmware-api-session-id: $SESSIONID' -k
```

https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/api/vcenter/vm/vm/get/


### delete vcenter api session
```
curl -k https://kitkat-vc.eng.vmware.com/api/session -X DELETE -H 'vmware-api-session-id: $SESSIONID' -kv
```


