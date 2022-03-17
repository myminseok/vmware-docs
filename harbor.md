## docker api
https://docs.docker.com/registry/spec/api/
```
export TOKEN=$(echo -n 'admin:VMware1!' | base64)


curl -k -X 'GET' -H "authorization: Basic $TOKEN"  -H 'accept: application/json' 'https://harbor1.haas-488.pez.vmware.com/v2/_catalog'
{"repositories":["test/echoserver","test/echoserver2","test/nginx"]}

```




## replication harbor api 

```
export TOKEN=$(echo -n 'admin:VMware1!' | base64)


curl -k -X 'GET' -H "authorization: Basic $TOKEN"  -H 'accept: application/json' \
'https://harbor1.haas-488.pez.vmware.com/api/v2.0/replication/executions'
[
  {
    "end_time": "2022-03-17T05:14:05.000Z",
    "failed": 0,
    "id": 6,
    "in_progress": 0,
    "policy_id": 1,
    "start_time": "2022-03-17T05:14:02.780Z",
    "status": "Succeed",
    "status_text": "",
    "stopped": 0,
    "succeed": 3,
    "total": 3,
    "trigger": "manual"
  },...
  ]


```
