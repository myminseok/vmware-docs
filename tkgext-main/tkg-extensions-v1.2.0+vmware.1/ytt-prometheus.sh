ytt --ignore-unknown-comments \
      -f common/ \
      -f monitoring/prometheus/  \
      -f ./extensions/monitoring/prometheus/vsphere/prometheus-data-values.yaml \
      -v infrastructure_provider=vsphere \
      -f ytt-adding-private-registry-secret.yml \
      -f ytt-prometheus-alertmanager-update.yml \
      -f ytt-prometheus-node-exporter-daemonset-update.yml

