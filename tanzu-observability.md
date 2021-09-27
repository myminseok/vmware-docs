
## Certificate Expiration Remains(days)-Certmanager
```
Expire-days: ts("certmanager.certificate.expiration.timestamp.seconds.gauge", cluster="${cluster_name}")/(3600*24)
Current-days: time()/(3600*24)
Remains-days: floor(${Expire-days}-${Current-days})
```

## Controlplane-inactive-node
```
aws: default(0, align(1m, count(lowpass(1, ts(kubernetes.node.status.condition, cluster="${cluster_name}" AND condition=Ready AND label.role=control-plane)))))
azure: default(0, align(1m, count(lowpass(1, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready" and label.node.kubernetes.io/instance-type=m5.xlarge)))))
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
