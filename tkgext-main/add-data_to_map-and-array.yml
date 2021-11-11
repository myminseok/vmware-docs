#@ load("@ytt:overlay", "overlay")
#@overlay/match by=overlay.subset({"kind": "DaemonSet", "metadata": {"name": "prometheus-node-exporter"}})
---
spec:
  template:
    spec:
      containers:
      #@overlay/match missing_ok=True
      #@overlay/match by="name"
      - name: prometheus-node-exporter
        args:
        #@overlay/match by=overlay.index(0)
        #@overlay/insert before=True
        - --path.pkifs=/etc/kubernetes/pki
        #@overlay/match missing_ok=True
        volumeMounts:
        #@overlay/match by=overlay.index(0)
        #@overlay/insert before=True
        - name: pki
          mountPath: /etc/kubernetes/pki
          readOnly: true
      volumes:
      #@overlay/match by=overlay.index(0)
      #@overlay/insert before=True
      - name: pki
        hostPath:
          path: /pki


        
