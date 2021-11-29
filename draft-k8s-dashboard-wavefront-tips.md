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

These tips are from the field experiences applying Wavefront on customer 
projects. It is intended to help implement dashboards but this is not supported 
by VMware.  Wavefront Query Language(WQL) is the language used to build queries 
implemented in these dashboards. For more detailed information, refer to the 
[Wavefront documentation](https://docs.wavefront.com/query_language_reference.html).

## General Consideration for WQL
- It is easier to debug if WQL is composed into smaller units. Better debugging 
visibility is achieved by changing the chart type to `table`
- For any charts showing it's current status, such as Active/Inactive charts, use the last 2 mins metrics for stable dashboard alerting to minimizing flip-flopping of events.  This is assuming that the Wavefront-proxy agent, by default, reports to Wavefront every 30 seconds. 
Also, apply the `at` function to use the latest time-series data. 
- For alerting, use the same WQL from the chart.

##  Variables for chart filter
Variables are used in WQL for the purposes of filtering. 
This can be defined in as many way as required, for example, to be able to 
filter from a selection of clusters, namespaces, pods etc.

### `cluster_name` 
This variable lists the clusters present and will be used for all proceeding queries in this document. 
The following query is from the Wavefront sample dashboard.

- variable Name: cluster_name
- variable type: Dynamic
- Field: Point Tag
- Point Tag Key: cluster
- Query: `collect(max(ts("kubernetes.cluster.cpu.limit"), cluster), taggify(1, cluster, "*"))`

## Tips
### Improving the `Active Nodes` chart

The original `Active Nodes` chart from [Wavefront Sample Dashboard](https://vmware.wavefront.com/dashboards/integration-kubernetes-clusters) shows all active nodes.

```wql
align(1m, count(ts("kubernetes.node.memory.working_set", cluster="${cluster_name}")))
```

This can be improved with the following query, which filters out inactive nodes 
by utilizing the `at` function to filter out old data and only use the latest 
data for accurate current state decisions. This will resolve the issue where it 
is observed that `Ready` and `Not Ready` state data for the same node is shown 
at the same time on Wavefront.

```wql
Ready_valid: at("now", 2m, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready" and status="True"))
Count: count(${Ready_valid})
```

### Improving the `Inactive Nodes` chart
The following is the original WQL from the example k8s dashboard provided by wavefront

```wql
default(0, align(1m, count(lowpass(1, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready")))))
```

The problem encountered with this query is that the default count does not show 
`0` if all nodes are in a `ready`state.  This can be resolved with the use of 
the `orElse()` function.

```wql
Ready_all_now: ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition=Ready and label.role="control-plane")
Ready_Invalid: lowpass(1, ${Ready_all_now})
Count: count(${Ready_Invalid}).orElse(0)
Default: default(0, align(1m, ${Count}))
```

The following single WQL is equivalent to above
```wql
default(0, align(1m, count(lowpass(1, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready"))).orElse(0)))
```

### Filtering nodes by Role (control plane or worker node)
Nodes can be filtered by its assigned role. This is achieved through labels that 
are placed on the cluster nodes. These labels may need to be applied on to 
control plane nodes of the source Kubernetes cluster in advanced, e.g., 
'label.role=control-plane'.  This will be required when any flavor of k8s that 
doesn't have common labels to distinguish the role of nodes. 
`prometheus-kube-state-metrics` from TKC should collect metrics automatically. 

Here are some examples:

- **Active Control Plane Nodes chart**

    The same WQL as the `Active Nodes` chart but using the label.role as a filter
    ```wql
    Ready_valid: at("now", 2m, ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition="Ready" and status="True" and label.role="control-plane"))
    Count: count(${Ready_valid})
    ```

- **Inactive Control Plane Nodes chart**

    The same WQL as the `Inactive Nodes` chart but using the label.role as a filter. 
    This also applies the `orElse()` per the [Improving the `Inactive Nodes` chart](#improving-the-inactive-nodes-chart) tip
    ```wql
    Ready_all_now: ts("kubernetes.node.status.condition", cluster="${cluster_name}" and condition=Ready and label.role="control-plane")
    Ready_Invalid: lowpass(1, ${Ready_all_now})
    Count: count(${Ready_Invalid}).orElse(0)
    Default: default(0, align(1m, ${Count}))
    ```

### Combining multiple metrics into single chart.
Multiple metrics can be combined into a single chart to help improve the readability.
This is achieved through the the use of the `aliasMetric` function. Here are
some examples:

- **Combining cpu, memory metrics for Kubernetes nodes**

    ```
    alloc_cpu_cores: aliasMetric(limit(250, ts("kubernetes.node.cpu.node_allocatable", cluster="${cluster_name}" and nodename="${node_name}")), "CPU Cores")/1000
    request_cpu_cores: aliasMetric(limit(250, ts("kubernetes.node.cpu.request", cluster="${cluster_name}" and nodename="${node_name}")), "CPU Request")/1000
    alloc_mem_bytes: aliasMetric(limit(250, ts("kubernetes.node.memory.node_allocatable", cluster="${cluster_name}" and nodename="${node_name}")), "Memory Bytes")
    request_mem_bytes: aliasMetric(limit(250, ts("kubernetes.node.memory.request", cluster="${cluster_name}" and nodename="${node_name}")), "Memory Request")
    ```

- **Node storage**

    Check column > group by source
    ```
    Total: round(aliasMetric(limit(250, ts("kubernetes.node.filesystem.limit", cluster="${cluster_name}" and nodename="${node_name}")), " Total(MB)")/(1024*1024))
    Used: round(aliasMetric(limit(250, ts("kubernetes.node.filesystem.usage", cluster="${cluster_name}" and nodename="${node_name}")), "Usage(MB)")/(1024*1024))
    UsageRate: round(aliasMetric(limit(250, ts("kubernetes.node.filesystem.usage", cluster="${cluster_name}" and nodename="${node_name}") / ts("kubernetes.node.filesystem.limit", cluster="${cluster_name}" and nodename="${node_name}")*100), "UsageRate(%)"))
    ```

### Showing Pod status

`kubernetes.pod.status.phase` metric is useful for checking availability. 
This is because the metric can distinguish the pod status.  We can use this to 
show a Pod Health via it's `Running` status. This is useful to alert on, when a 
pod is not running. This metric can be appled to TKG and Openshift.

```
ts("kubernetes.pod.status.phase", cluster="<APP CLUSTERNAME>" and nodename="*" and namespace_name="<APP_NAMESPACE>" and pod_name="*" and phase="Running")
```

Here is an example alert rule for a failing Pod Alert for a specific app:

```
count(ts("kubernetes.pod.status.phase", cluster="<APP CLUSTERNAME>" and nodename="*" and namespace_name="<APP_NAMESPACE>" and pod_name="yelb-ui-*" and phase="Running")) < 1 
```

### Showing PVC capacity
It is a common request to have visibility into the capacity of PVs. 
The `kube.persistentvolumeclaim.resource.requests.storage.bytes.gauge` metric 
only shows the `requested` size of PV. In order to get the `used` capacity metric (`kubernetes.pod.filesystem.usage`), 
install the [`kube-state-metrics`](https://github.com/kubernetes/kube-state-metrics).
Refer to the [Wavefront guide](https://docs.wavefront.com/kubernetes.html#step-3-optional-deploy-the-kube-state-metrics-service) 
on how to install `kube-state-metrics`. The only disadvantage of this metric is that 
it does not have a common key between these two metrics to do a join.  

Here is an example of using the `used` capacity metric:

```
Used: aliasMetric(ts("kubernetes.pod.filesystem.usage" , cluster="${cluster_name}" and namespace_name="${namespace}"), "Used")
Capacity: aliasMetric(ts("kube.persistentvolumeclaim.resource.requests.storage.bytes.gauge" and cluster="${cluster_name}" and namespace="${namespace}"), "Capacity")
```

### Showing Certificate Expiration Remains(days)

This method only shows the deployments with the following cert-manager 
annotation. It is automatically added all `Ingress` and `HttpProxy` custom 
resources via the Contour extension/package which leverages cert-manager.

```yaml
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

the TLS will be shown up to cert-manager metrics via the WQL

```
Expire-days: ts("certmanager.certificate.expiration.timestamp.seconds.gauge", cluster="${cluster_name}")/(3600*24)
Current-days: time()/(3600*24)
Remains-days: floor(${Expire-days}-${Current-days})
```

### Showing Certificates expiration of Kubernetes components via the `x509-certificate-exporter` 

To retrieve metrics to display the certificate expiration of certificates in ` /etc/kubernetes/pki` for Kubernetes components,
use the [x509-certificate-exporter](https://artifacthub.io/packages/helm/enix/x509-certificate-exporter). Once this 
exporter is installed, the metrics are available on the `/metrics` endpoint.
