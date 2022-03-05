# error from ako-0 pod when deploying ingress without contour
pool group: tkc-noavi--Shared-L7-6 is for AVI L7
```
2021-12-19T10:35:11.489Z	WARN	rest/rest_operation.go:268	RestOp method POST path /api/poolgroup/ tenant admin Obj {"cloud_config_cksum":"1996966820","cloud_ref":"/api/cloud?name=Default-Cloud","created_by":"ako-tkc-noavi","implicit_priority_labels":true,"name":"tkc-noavi--Shared-L7-6","tenant_ref":"/api/tenant/?name=admin"} returned err {"code":0,"message":"map[error:PoolGroup: Object PoolGroup is not allowed under ESSENTIALS license tier.]","Verb":"POST","Url":"https://avi.lab.pcfdemo.net//api/poolgroup/","HttpStatusCode":400}
```
