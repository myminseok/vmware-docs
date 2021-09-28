
## Certificate Expiration Remains(days)-Certmanager
```
Expire-days: ts("certmanager.certificate.expiration.timestamp.seconds.gauge", cluster="${cluster_name}")/(3600*24)
Current-days: time()/(3600*24)
Remains-days: floor(${Expire-days}-${Current-days})
```

## control plane active node
- need to label the control plane nodes to  'label.role=control-plane'
- prometheus-kube-state-metrics should collect metrics.
- wavefront-proxy reports to TO every 30 sec
- `at` function limits the latest timeseries data. 2min was best fit based on testing on azure. 
```wql
Ready_valid: at("now", 2m, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready" and status="True" and label.role="control-plane"))
Count: count(${Ready_valid})
```
## Controlplane-inactive-node

```wql
Ready_all_now: at("now", 2m, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition=Ready and label.role="control-plane"))
Ready_Invalid: lowpass(1, ${Ready_all_now})
Count: default(0,count(${Ready_Invalid}).orElse(0))

```

## PVC-used
```
ts("kubernetes.pod.filesystem.usage" , cluster="${cluster_name}" and namespace_name="${namespace}")
```

## PVC-capacity
install kube-state-metrics
```
ts(kube.persistentvolumeclaim.resource.requests.storage.bytes.gauge and cluster=${cluster_name})
```

## controlplane component status
```
etcd: ts("kube.pod.status.ready.gauge", cluster="${cluster_name}" and pod="etcd*" and condition=true)
coredns: ts("kube.pod.status.ready.gauge", cluster="${cluster_name}" and pod="coredns*" and condition=true)
kube-*: ts("kube.pod.status.ready.gauge", cluster="${cluster_name}" and pod="kube-*" and condition=true)

```

### aliasMetric
```
alloc_cpu_cores: aliasMetric(limit(250, ts("kubernetes.node.cpu.node_allocatable", cluster="${cluster_name}" and nodename="${node_name}")), "CPU Cores")/1000
request_cpu_cores: aliasMetric(limit(250, ts("kubernetes.node.cpu.request", cluster="${cluster_name}" and nodename="${node_name}")), "CPU Request")/1000
alloc_mem_bytes: aliasMetric(limit(250, ts("kubernetes.node.memory.node_allocatable", cluster="${cluster_name}" and nodename="${node_name}")), "Memory Bytes")
request_mem_bytes: aliasMetric(limit(250, ts("kubernetes.node.memory.request", cluster="${cluster_name}" and nodename="${node_name}")), "Memory Request")
```
