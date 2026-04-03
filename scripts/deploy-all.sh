#!/bin/bash
# deploy-all.sh — build, push, and deploy all services to the k3s cluster
set -e

REGISTRY="192.168.56.20:5001"     # jenkins-agent VM hosts the registry
HOST_REGISTRY="192.168.56.20:5001"

# ── 1. Ensure local registry is running ─────────────────────────────────────
if ! docker ps --filter "name=^registry$" --filter "status=running" --format '{{.Names}}' | grep -q "^registry$"; then
  echo "Starting local registry on port 5001..."
  docker start registry 2>/dev/null || \
    docker run -d -p 5001:5000 --restart=always --name registry \
      -v ~/registry-data:/var/lib/registry registry:2
fi

# ── 2. Build & push Spring Boot backend ─────────────────────────────────────
echo ""
echo ">>> Building commitment-tracker-api..."
docker build -t ${REGISTRY}/commitment-tracker-api:latest ./backend/commitment-tracker
docker push ${REGISTRY}/commitment-tracker-api:latest

# ── 3. Build & push React frontend ──────────────────────────────────────────
echo ""
echo ">>> Building commitment-tracker-frontend..."
docker build -t ${REGISTRY}/commitment-tracker-frontend:latest ./frontend/commitment-tracker
docker push ${REGISTRY}/commitment-tracker-frontend:latest

# ── 4. Apply all manifests and restart deployments ──────────────────────────
echo ""
echo ">>> Applying Kubernetes manifests..."
vagrant ssh k3s-master -- bash -s << 'EOF'
set -e

# Infrastructure (idempotent)
kubectl apply -f /vagrant/platform/mongodb/mongodb.yaml
kubectl apply -f /vagrant/platform/mongodb/mongo-express.yaml

# App deployments
kubectl apply -f /vagrant/manifests/commitment-tracker/spring-commitment-tracker.yaml
kubectl apply -f /vagrant/manifests/commitment-tracker/react-commitment-tracker.yaml

# Ingress rules
kubectl apply -f /vagrant/manifests/commitment-tracker/ingress.yaml

# Headlamp dashboard
kubectl apply -f /vagrant/platform/headlamp/headlamp.yaml

# Force pods to re-pull the latest image
kubectl rollout restart deployment/commitment-tracker-api
kubectl rollout restart deployment/commitment-tracker-frontend

echo ""
echo "Waiting for rollouts..."
kubectl rollout status deployment/commitment-tracker-api     --timeout=120s
kubectl rollout status deployment/commitment-tracker-frontend --timeout=120s
kubectl rollout status deployment/mongo-express               --timeout=120s

echo ""
echo "=== Pods ==="
kubectl get pods

echo ""
echo "=== Services ==="
kubectl get svc

echo ""
echo "=== Ingress ==="
kubectl get ingress

echo ""
echo "Waiting for MetalLB to assign external IPs (this can take ~60s)..."

wait_for_ip() {
  local ns=$1 svc=$2 label=$3
  for i in $(seq 1 60); do
    IP=$(kubectl get svc "$svc" -n "$ns" \
      -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
    [ -n "$IP" ] && echo "$IP" && return
    sleep 2
  done
  echo "<pending — MetalLB not ready yet>"
}

INGRESS_IP=$(wait_for_ip kube-system traefik)
MONGO_IP=$(wait_for_ip default mongo-express)
HEADLAMP_IP=$(wait_for_ip kube-system headlamp)

# Save token for Headlamp login
kubectl get secret headlamp-token -n kube-system \
  -o jsonpath='{.data.token}' 2>/dev/null | base64 -d > /vagrant/headlamp.token && echo "" || true

echo ""
echo "✅  App:           http://${INGRESS_IP}/"
echo "✅  API:           http://${INGRESS_IP}/api/commitments-one"
echo "✅  Mongo Express: http://${MONGO_IP}:8081/"
echo "✅  Headlamp:      http://${HEADLAMP_IP}/"
EOF
