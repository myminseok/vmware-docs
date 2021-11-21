
## active Controlplane node
- need to label the control plane nodes to  'label.role=control-plane'
- prometheus-kube-state-metrics should collect metrics.
- wavefront-proxy reports to TO every 30 sec
- `at` function limits the latest timeseries data. 2min was best fit based on testing on azure.
- use chart type: single stat

```wql
Ready_valid: at("now", 2m, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready" and status="True" and label.role="control-plane"))
Count: count(${Ready_valid})
```
or
```
sum( ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready" and status=True and label.role="control-plane").gt(0), Sources, condition, label.role)
```

##  inactive node

```wql
# original sql from example k8s dashboard providesd by wavefront
default(0, align(1m, count(lowpass(1, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready")))))

```

# custom wql putting orElse() function.
```wql
Ready_all_now: ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition=Ready and label.role="control-plane")
Ready_Invalid: lowpass(1, ${Ready_all_now})
Count: count(${Ready_Invalid}).orElse(0)
Default: default(0, align(1m, ${Count}))
```
equvelant single wql

```wql
default(0, align(1m, count(lowpass(1, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready"))).orElse(0)))
```


### Node CPU, Memory request/allocated (combinded charts using aliasMetric function)
- 
```
alloc_cpu_cores: aliasMetric(limit(250, ts("kubernetes.node.cpu.node_allocatable", cluster="${cluster_name}" and nodename="${node_name}")), "CPU Cores")/1000
request_cpu_cores: aliasMetric(limit(250, ts("kubernetes.node.cpu.request", cluster="${cluster_name}" and nodename="${node_name}")), "CPU Request")/1000
alloc_mem_bytes: aliasMetric(limit(250, ts("kubernetes.node.memory.node_allocatable", cluster="${cluster_name}" and nodename="${node_name}")), "Memory Bytes")
request_mem_bytes: aliasMetric(limit(250, ts("kubernetes.node.memory.request", cluster="${cluster_name}" and nodename="${node_name}")), "Memory Request")
```
## Node storage (aliasMetric function)
- check column > group by source
```
Total: round(aliasMetric(limit(250, ts("kubernetes.node.filesystem.limit", cluster="${cluster_name}" and nodename="${node_name}")), " Total(MB)")/(1024*1024))
Used: round(aliasMetric(limit(250, ts("kubernetes.node.filesystem.usage", cluster="${cluster_name}" and nodename="${node_name}")), "Usage(MB)")/(1024*1024))
UsageRate: round(aliasMetric(limit(250, ts("kubernetes.node.filesystem.usage", cluster="${cluster_name}" and nodename="${node_name}") / ts("kubernetes.node.filesystem.limit", cluster="${cluster_name}" and nodename="${node_name}")*100), "UsageRate(%)"))
```


## PVC summary ( no join key)
- install kube-state-metrics for "kube.persistentvolumeclaim.resource.requests.storage.bytes.gauge"
- there is no common key between the two metrics for Join.
```
Used: aliasMetric(ts("kubernetes.pod.filesystem.usage" , cluster="${cluster_name}" and namespace_name="${namespace}"), "Used")
Capacity: aliasMetric(ts("kube.persistentvolumeclaim.resource.requests.storage.bytes.gauge" and cluster="${cluster_name}" and namespace="${namespace}"), "Capacity")
```

## POD status (TKG only)
- this metric only valid to show running pod list. it cannot distinguish the failed pod list.
- this metic doesn't compatible with openshift
```
etcd: ts("kube.pod.status.ready.gauge", cluster="${cluster_name}" and pod="etcd*" and condition=true)
coredns: ts("kube.pod.status.ready.gauge", cluster="${cluster_name}" and pod="coredns*" and condition=true)
kube-*: ts("kube.pod.status.ready.gauge", cluster="${cluster_name}" and pod="kube-*" and condition=true)
```

## POD status(TKG + openshift)
- if pod fail, or not exist, then the Running metric disapears, so that we can check pod status.
```
ts("kubernetes.pod.status.phase", cluster="<APP CLUSTERNAME>" and nodename="*" and namespace_name="<APP_NAMESPACE>" and pod_name="yelb-ui-*" and phase="Running")
```

## Pod not running alert rule
```
count(ts("kubernetes.pod.status.phase", cluster="<APP CLUSTERNAME>" and nodename="*" and namespace_name="<APP_NAMESPACE>" and pod_name="yelb-ui-*" and phase="Running")) < 1 
```


## Certificate Expiration Remains(days)-Certmanager
- put annotation to Ingress with certs
```
Kind: Ingress
metadata:
  annotations:  
    cert-manager.io/cluster-issuer: selfsigned-issuer
    ...
spec:
  tls:
  - hosts:
    - yelb.com
    secretName: yelb-tls
```
- the tls will be shown up to cert-manager metrics.
```wql
Expire-days: ts("certmanager.certificate.expiration.timestamp.seconds.gauge", cluster="${cluster_name}")/(3600*24)
Current-days: time()/(3600*24)
Remains-days: floor(${Expire-days}-${Current-days})
```

