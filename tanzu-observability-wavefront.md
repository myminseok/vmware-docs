
# General Considerations for WQL
- It is easier to debug if compose smaller unit of WQL for better visibility when debugging by change the chart type to `table`
- for the charts using the current status such as Active/Inactive charts, consider that the Wavefront-proxy agent reports to Wavefront every 30 secondes. it make sense to use the last 2 mins metrics for stable dashboard alerting. 
- `at` function limits the latest timeseries data. 
- for alert, use the same WQL from the chart.


# `cluster_name` variable for chart filter:
- variable Name: cluster_name
- variable type: Dynamic
- Field: Point Tag
- Point Tag Key: cluster
- Query: collect(max(ts("kubernetes.cluster.cpu.limit"), cluster), taggify(1, cluster, "*"))


# Active Nodes chart
The Original Active Node chart from [Wavefront Sample Dashboard](https://vmware.wavefront.com/dashboards/integration-kubernetes-clusters) shows all nodes without filters

### Original Active Node chart from [Wavefront Sample Dashboard](https://vmware.wavefront.com/dashboards/integration-kubernetes-clusters)
```wql
align(1m, count(ts("kubernetes.node.memory.working_set", cluster="${cluster_name}")))
```
### Improved Active Node chart 
```wql
Ready_valid: at("now", 2m, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready" and status="True"))
Count: count(${Ready_valid})
```

# Inactive Nodes chart
### original sql from example k8s dashboard providesd by wavefront
```wql
default(0, align(1m, count(lowpass(1, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready")))))
```
### custom wql 
- uses orElse() function to show the default `0` if all nodes is `ready`state. 
```wql
Ready_all_now: ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition=Ready and label.role="control-plane")
Ready_Invalid: lowpass(1, ${Ready_all_now})
Count: count(${Ready_Invalid}).orElse(0)
Default: default(0, align(1m, ${Count}))
```
or equvelant single wql
```wql
default(0, align(1m, count(lowpass(1, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready"))).orElse(0)))
```

# To filter node by role (control plane or worker node )
- need to label the control plane nodes to 'label.role=control-plane' on the source kubernetes cluster in advance. this is required that every k8s cluster from different ventor/cloud doesn't have common labels to distinghush the role of nodes.
- prometheus-kube-state-metrics should collect metrics.

### Active Control Plane Nodes chart
- the same WQL with active Nodes chart but puttig label.role filter
```wql
Ready_valid: at("now", 2m, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready" and status="True" and label.role="control-plane"))
Count: count(${Ready_valid})
```

###  Inactive Control Plane Nodes chart
- the same WQL with Inactive Nodes chart but puttig label.role filter
- uses orElse() function to show the default `0` if all nodes is `ready`state. 
```wql
Ready_all_now: ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition=Ready and label.role="control-plane")
Ready_Invalid: lowpass(1, ${Ready_all_now})
Count: count(${Ready_Invalid}).orElse(0)
Default: default(0, align(1m, ${Count}))
```


# Node CPU, Memory request/allocated (combinded charts using aliasMetric function)

```
alloc_cpu_cores: aliasMetric(limit(250, ts("kubernetes.node.cpu.node_allocatable", cluster="${cluster_name}" and nodename="${node_name}")), "CPU Cores")/1000
request_cpu_cores: aliasMetric(limit(250, ts("kubernetes.node.cpu.request", cluster="${cluster_name}" and nodename="${node_name}")), "CPU Request")/1000
alloc_mem_bytes: aliasMetric(limit(250, ts("kubernetes.node.memory.node_allocatable", cluster="${cluster_name}" and nodename="${node_name}")), "Memory Bytes")
request_mem_bytes: aliasMetric(limit(250, ts("kubernetes.node.memory.request", cluster="${cluster_name}" and nodename="${node_name}")), "Memory Request")
```
# Node storage (aliasMetric function)
- check column > group by source
```
Total: round(aliasMetric(limit(250, ts("kubernetes.node.filesystem.limit", cluster="${cluster_name}" and nodename="${node_name}")), " Total(MB)")/(1024*1024))
Used: round(aliasMetric(limit(250, ts("kubernetes.node.filesystem.usage", cluster="${cluster_name}" and nodename="${node_name}")), "Usage(MB)")/(1024*1024))
UsageRate: round(aliasMetric(limit(250, ts("kubernetes.node.filesystem.usage", cluster="${cluster_name}" and nodename="${node_name}") / ts("kubernetes.node.filesystem.limit", cluster="${cluster_name}" and nodename="${node_name}")*100), "UsageRate(%)"))
```

# POD status
### POD status by platform process (TKG only)
- this metric only valid to show running pod list. it cannot distinguish the failed pod list.
- this metic doesn't compatible with openshift
```
etcd: ts("kube.pod.status.ready.gauge", cluster="${cluster_name}" and pod="etcd*" and condition=true)
coredns: ts("kube.pod.status.ready.gauge", cluster="${cluster_name}" and pod="coredns*" and condition=true)
kube-*: ts("kube.pod.status.ready.gauge", cluster="${cluster_name}" and pod="kube-*" and condition=true)
```

### POD status(TKG + openshift)
- if pod fail, or not exist, then the Running metric disapears, so that we can check pod status.
```
ts("kubernetes.pod.status.phase", cluster="<APP CLUSTERNAME>" and nodename="*" and namespace_name="<APP_NAMESPACE>" and pod_name="yelb-ui-*" and phase="Running")
```

### Failing Pod Alert rule for specific App.
```
count(ts("kubernetes.pod.status.phase", cluster="<APP CLUSTERNAME>" and nodename="*" and namespace_name="<APP_NAMESPACE>" and pod_name="yelb-ui-*" and phase="Running")) < 1 
```


# PVC summary ( no join key)
- install kube-state-metrics for "kube.persistentvolumeclaim.resource.requests.storage.bytes.gauge"
- there is no common key between the two metrics for Join.
```
Used: aliasMetric(ts("kubernetes.pod.filesystem.usage" , cluster="${cluster_name}" and namespace_name="${namespace}"), "Used")
Capacity: aliasMetric(ts("kube.persistentvolumeclaim.resource.requests.storage.bytes.gauge" and cluster="${cluster_name}" and namespace="${namespace}"), "Capacity")
```

# Certificate Expiration Remains(days)

###  using cert manager
this method only shows the deployments with following cert-manager annotations, contour extensions
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
- the TLS will be shown up to cert-manager metrics.
```wql
Expire-days: ts("certmanager.certificate.expiration.timestamp.seconds.gauge", cluster="${cluster_name}")/(3600*24)
Current-days: time()/(3600*24)
Remains-days: floor(${Expire-days}-${Current-days})
```

### Node Exporter
TBD




