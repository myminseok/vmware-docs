### podAntiAffinity
https://kubernetes.io/ko/docs/concepts/scheduling-eviction/assign-pod-node/
```
apiVersion:
Kind: Deployment
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: yelb-ui
        tier: frontend
    spec:
      tolerations:
      - key: "node.kubernetes.io/unreachable"
        operator: "Exists"
        effect: "NoExecute"
        tolerationSeconds: 1
      - key: "node.kubernetes.io/not-ready"
        operator: "Exists"
        effect: "NoExecute"
        tolerationSeconds: 1
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution :
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
               - yelb-ui
            topologyKey: "kubernetes.io/hostname"
        containers:
        - name: yelb-ui
          image: 
          ports:
          - containerPort: 80
          livenessProbe:
            httpGet:
              path: /
              port: 80
            timeoutSeconds: 1
```

### azure internal loadbalancer
```
apiVersion: v1
kind: Service
metadata:
  name: yelb-ui
  labels:
    app: yelb-ui
    tier: frontend
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: yelb-ui
    tier: frontend
```
### azure pvc
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-data
  ...
  annotations:
    volue.beta.kubernetes.io/storage-provisioner: kubernetes.io/azure-file
spec:
  storageClassName: azurefile
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 2Gi
```
