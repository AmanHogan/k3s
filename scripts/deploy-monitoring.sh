#!/bin/bash
# deploy-monitoring.sh — install Prometheus + Grafana via Helm into the k3s cluster
#
# Run this once after `vagrant up` and `deploy-all.sh`.
# Safe to re-run; Helm upgrade is idempotent.
#
# Access after install:
#   Grafana:    http://<GRAFANA_IP>/   (login: admin / admin)
#   Prometheus: http://<PROMETHEUS_IP>/
set -e

echo ">>> Installing kube-prometheus-stack + Loki..."
vagrant ssh k3s-master -- bash -s << 'EOF'
set -e

# Add Helm repos (idempotent)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo add grafana https://grafana.github.io/helm-charts 2>/dev/null || true
helm repo update

# Install Loki + Promtail (log aggregation)
# Promtail runs on every node and ships pod logs to Loki
helm upgrade --install loki grafana/loki-stack \
  --namespace monitoring --create-namespace \
  --set loki.persistence.enabled=false \
  --set promtail.enabled=true \
  --timeout 5m \
  --wait

# loki-stack creates a Grafana datasource ConfigMap with isDefault: true,
# but kube-prometheus-stack also provisions Prometheus as default.
# Grafana 12.x hard-fails if two datasources are default — patch Loki to false.
kubectl patch configmap loki-loki-stack -n monitoring --type merge \
  -p '{"data":{"loki-stack-datasource.yaml":"apiVersion: 1\ndatasources:\n- name: Loki\n  type: loki\n  access: proxy\n  url: \"http://loki:3100\"\n  version: 1\n  isDefault: false\n  jsonData:\n    {}\n"}}' 2>/dev/null || true

# Install or upgrade the monitoring stack
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --values /vagrant/platform/monitoring/values.yaml \
  --timeout 15m \
  --wait

echo ""
echo "Waiting for Grafana to get an external IP..."
for i in $(seq 1 30); do
  GRAFANA_IP=$(kubectl get svc -n monitoring monitoring-grafana \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
  if [ -n "$GRAFANA_IP" ]; then break; fi
  sleep 5
done

PROMETHEUS_IP=$(kubectl get svc -n monitoring monitoring-kube-prometheus-prometheus \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)

echo ""
echo "=== Monitoring pods ==="
kubectl get pods -n monitoring

echo ""
echo "✅  Grafana:    http://${GRAFANA_IP}/    (admin / admin)"
echo "✅  Prometheus: http://${PROMETHEUS_IP}/"
echo ""
echo "In Grafana → Explore → select Loki datasource to query logs."
echo "Example query: {namespace=\"default\", app=\"commitment-tracker-api\"}"
EOF
