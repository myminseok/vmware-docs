---
title: "Customizing Tips for Kubernetes Dashboard on Wavefront"
weight: 1501
aliases: [
  "/observability/guides/k8s-dashboard-wavefront-tips.md"
]
keywords:
  - "platform-tkg"
  - "observability"
  - "library"

tags:
- "Kubernetes"
- "TKG"
- "Wavefront"
- "Monitoring"

---


This tips are from the field experiences applying Wavefront on customer project. it is intended to help implementing Dashboard but not something guaranteed or supported from VMware. you can refer to the [Wavefront documentation](https://docs.wavefront.com/query_language_reference.html) for detailed information on Wavefront Query Language(WQL)

## General Consideration for WQL
- It is easier to debug if compose smaller unit of WQL for better visibility when debugging by change the chart type to `table`
- for any charts to show current status such as Active/Inactive charts, it is magic number to use the last 2 mins metrics for stable dashboard alerting ( minimizing flip-flop in the event), considering the Wavefront-proxy agent reports to Wavefront every 30 seconds. use `at` function to use the latest timeseries data. 
- for alert, use the same WQL from the chart.

##  Variables for chart filter
variables is a filter to be used to in the WQL. you can define as many as you can. such as cluster list , namespace list, pod list, etc.
### `cluster_name` 
this variable lists up clusters available. Following Query is from Wavefront sample dashboard, and will be used in the following chart.
- variable Name: cluster_name
- variable type: Dynamic
- Field: Point Tag
- Point Tag Key: cluster
- Query: `collect(max(ts("kubernetes.cluster.cpu.limit"), cluster), taggify(1, cluster, "*"))`

## Active Nodes chart
### Original Active Node chart 
The Original Active Node chart from [Wavefront Sample Dashboard](https://vmware.wavefront.com/dashboards/integration-kubernetes-clusters) shows all nodes.
```wql
align(1m, count(ts("kubernetes.node.memory.working_set", cluster="${cluster_name}")))
```
###  improved Active Node chart
you may improve Active Node chart as following. for unknown reasons, you may observe that `Ready` and `Not Ready` state data for the same node at the sametime on Wavefront. you need to filter inactive nodes when the events happening. and better to use `at` fundtion to filter out old data and only use the latest data for acurate state decision.
```wql
Ready_valid: at("now", 2m, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready" and status="True"))
Count: count(${Ready_valid})
```

## Inactive Nodes chart
### original WQL from example k8s dashboard provided by wavefront
```wql
default(0, align(1m, count(lowpass(1, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready")))))
```
### improved Inactive Nodes chart (TBD)
you may see the defaut count is not working to show `0` if all nodes is `ready`state. uses `orElse()` function additionally to make sure to show the default `0`. 
```wql
Ready_all_now: ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition=Ready and label.role="control-plane")
Ready_Invalid: lowpass(1, ${Ready_all_now})
Count: count(${Ready_Invalid}).orElse(0)
Default: default(0, align(1m, ${Count}))
```
following single WQL is equvelant to above.
```wql
default(0, align(1m, count(lowpass(1, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready"))).orElse(0)))
```

## To filter node by Role (control plane or worker node)
- you may need to label the control plane nodes to 'label.role=control-plane' on the source kubernetes cluster in advance. this is required that every k8s cluster from different ventor/cloud doesn't have common labels to distinghush the role of nodes. `prometheus-kube-state-metrics` from TKC should collect metrics automatically.

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


## Combining multiple metrics into single chart.
sometimes, putting relevent metrics into a single chart is useful with aliasMetric function. 

### cpu, memory metrics for kubernetes nodes
```
alloc_cpu_cores: aliasMetric(limit(250, ts("kubernetes.node.cpu.node_allocatable", cluster="${cluster_name}" and nodename="${node_name}")), "CPU Cores")/1000
request_cpu_cores: aliasMetric(limit(250, ts("kubernetes.node.cpu.request", cluster="${cluster_name}" and nodename="${node_name}")), "CPU Request")/1000
alloc_mem_bytes: aliasMetric(limit(250, ts("kubernetes.node.memory.node_allocatable", cluster="${cluster_name}" and nodename="${node_name}")), "Memory Bytes")
request_mem_bytes: aliasMetric(limit(250, ts("kubernetes.node.memory.request", cluster="${cluster_name}" and nodename="${node_name}")), "Memory Request")
```

###  Node storage
- check column > group by source
```
Total: round(aliasMetric(limit(250, ts("kubernetes.node.filesystem.limit", cluster="${cluster_name}" and nodename="${node_name}")), " Total(MB)")/(1024*1024))
Used: round(aliasMetric(limit(250, ts("kubernetes.node.filesystem.usage", cluster="${cluster_name}" and nodename="${node_name}")), "Usage(MB)")/(1024*1024))
UsageRate: round(aliasMetric(limit(250, ts("kubernetes.node.filesystem.usage", cluster="${cluster_name}" and nodename="${node_name}") / ts("kubernetes.node.filesystem.limit", cluster="${cluster_name}" and nodename="${node_name}")*100), "UsageRate(%)"))
```

## Pod status
`kubernetes.pod.status.phase` metric is useful for checking availability, because the metric can distinguish the pod stauts.

### POD health
shows only pod with `Running` status, so useful to alert if it is not running. this metric can apply to TKG and Openshift
```
ts("kubernetes.pod.status.phase", cluster="<APP CLUSTERNAME>" and nodename="*" and namespace_name="<APP_NAMESPACE>" and pod_name="*" and phase="Running")
```

### Failing Pod Alert rule for specific App.
```
count(ts("kubernetes.pod.status.phase", cluster="<APP CLUSTERNAME>" and nodename="*" and namespace_name="<APP_NAMESPACE>" and pod_name="yelb-ui-*" and phase="Running")) < 1 
```

## PVC summary
it is common requirement to see usage of PV. `kube.persistentvolumeclaim.resource.requests.storage.bytes.gauge` metric only shows the request size of PV. and you need to install [`kube-state-metrics`](https://github.com/kubernetes/kube-state-metrics) for used size of PV. refer to the [Wavefront guide](https://docs.wavefront.com/kubernetes.html#step-3-optional-deploy-the-kube-state-metrics-service) for `kube-state-metrics` installation.
but issues here is that there is no common key between the two metrics for joining.
```
Used: aliasMetric(ts("kubernetes.pod.filesystem.usage" , cluster="${cluster_name}" and namespace_name="${namespace}"), "Used")
Capacity: aliasMetric(ts("kube.persistentvolumeclaim.resource.requests.storage.bytes.gauge" and cluster="${cluster_name}" and namespace="${namespace}"), "Capacity")
```

## Certificate Expiration Remains(days)

###  using cert manager
this method only shows the deployments with following cert-manager annotations. it is added allIngress/HttProxy resources with Contour extensions which leveraging cert-manager.
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

### using `x509-certificate-exporter` for kubernetes component Certificates Expiration
you may wants to show certificate expiracy for kubernets component, located on /etc/kubernetes/pki. once you install [x509-certificate-exporter](https://artifacthub.io/packages/helm/enix/x509-certificate-exporter) exporter will automatically expose to `/metrics` endopints.






