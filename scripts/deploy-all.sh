#!/bin/bash
# deploy-all.sh — build, push, and deploy all services to the k3s cluster
set -e

BACKEND_PATH="../commitment-tracker/backend"       # Spring Boot app repo
FRONTEND_PATH="../commitment-tracker/frontend"     # Next.js frontend repo

# Push images to the registry on the Jenkins agent VM.
# k3s nodes also pull from 192.168.56.20:5001 in Option A.
PUSH_REGISTRY="192.168.56.20:5001"          # Push images to Jenkins registry
CLUSTER_REGISTRY="192.168.56.20:5001"       # k8s manifests reference this (VMs pull from Jenkins agent)

# ── 1. Ensure the Jenkins-agent registry is reachable ───────────────────────
if ! curl -fsS http://192.168.56.20:5001/v2/ >/dev/null 2>&1; then
  echo "ERROR: Registry at 192.168.56.20:5001 is not reachable."
  echo "Start the Jenkins agent VM and ensure the registry is running."
  exit 1
fi

# ── 2. Build & push Spring Boot backend ─────────────────────────────────────
echo ""
echo ">>> Building commitment-tracker-api..."
docker build -t ${PUSH_REGISTRY}/commitment-tracker-api:latest ${BACKEND_PATH}
docker push ${PUSH_REGISTRY}/commitment-tracker-api:latest

# ── 3. Build & push React frontend ──────────────────────────────────────────
echo ""
echo ">>> Building commitment-tracker-frontend..."
docker build -t ${PUSH_REGISTRY}/commitment-tracker-frontend:latest ${FRONTEND_PATH}
docker push ${PUSH_REGISTRY}/commitment-tracker-frontend:latest

# ── 4. Apply all manifests and restart deployments ──────────────────────────
echo ""
echo ">>> Applying Kubernetes manifests..."
vagrant ssh k3s-master -- bash -s << 'EOF'
# (no set -e — rollout timeouts are non-fatal so we always print IPs)

# Namespace must exist before everything else
kubectl apply -f /vagrant/manifests/commitment-tracker/namespace.yaml

# Postgres (Secret, ConfigMap, StatefulSet, Service)
kubectl apply -f /vagrant/manifests/commitment-tracker/postgres.yaml

# App deployments
kubectl apply -f /vagrant/manifests/commitment-tracker/spring-commitment-tracker.yaml
kubectl apply -f /vagrant/manifests/commitment-tracker/react-commitment-tracker.yaml

# Ingress rules
kubectl apply -f /vagrant/manifests/commitment-tracker/ingress.yaml

# Headlamp dashboard
kubectl apply -f /vagrant/platform/headlamp/headlamp.yaml

# ── ArgoCD Application CR ────────────────────────────────────────────────────
# Re-apply on every deploy so destination namespace never drifts from the repo.
kubectl apply -f /vagrant/argocd-apps/commitment-tracker.yaml

# ── ArgoCD repo-server health check ─────────────────────────────────────────
# If the repo-server pod is stuck in Unknown, force-delete it so it reschedules.
REPO_SERVER_STATUS=$(kubectl get pod -n argocd -l app.kubernetes.io/name=argocd-repo-server \
  -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "Missing")
if [ "$REPO_SERVER_STATUS" != "Running" ]; then
  echo "⚠️  argocd-repo-server is $REPO_SERVER_STATUS — force-deleting to reschedule..."
  kubectl delete pod -n argocd -l app.kubernetes.io/name=argocd-repo-server \
    --force --grace-period=0 2>/dev/null || true
  # Wait up to 60s for it to come back
  for i in $(seq 1 20); do
    STATUS=$(kubectl get pod -n argocd -l app.kubernetes.io/name=argocd-repo-server \
      -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
    [ "$STATUS" = "Running" ] && echo "✅  argocd-repo-server recovered" && break
    sleep 3
  done
fi

# Force ArgoCD to re-compare manifests after every deploy
kubectl annotate application commitment-tracker -n argocd \
  argocd.argoproj.io/refresh=hard --overwrite 2>/dev/null || true

# Wait for Postgres (non-blocking — app pods will retry via init container)
echo ""
echo "Waiting for Postgres to be ready (non-blocking)..."
kubectl rollout status statefulset/postgres -n commitment-tracker --timeout=60s || \
  echo "⚠️  Postgres not ready yet — app pods will retry automatically via init container"

# Force pods to re-pull the latest image
kubectl rollout restart deployment/commitment-tracker-api     -n commitment-tracker
kubectl rollout restart deployment/commitment-tracker-frontend -n commitment-tracker

echo ""
echo "Waiting for rollouts (non-blocking — continuing to show IPs regardless)..."
kubectl rollout status deployment/commitment-tracker-api     -n commitment-tracker --timeout=180s || \
  echo "⚠️  API rollout still in progress — check 'kubectl get pods -n commitment-tracker'"
kubectl rollout status deployment/commitment-tracker-frontend -n commitment-tracker --timeout=60s || \
  echo "⚠️  Frontend rollout still in progress"

echo ""
echo "=== Pods ==="
kubectl get pods -n commitment-tracker

echo ""
echo "=== Services ==="
kubectl get svc -n commitment-tracker

echo ""
echo "=== Ingress ==="
kubectl get ingress -n commitment-tracker

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
HEADLAMP_IP=$(wait_for_ip kube-system headlamp)

# Save token for Headlamp login
kubectl get secret headlamp-token -n kube-system \
  -o jsonpath='{.data.token}' 2>/dev/null | base64 -d > /vagrant/headlamp.token && echo "" || true

echo ""
echo "✅  App:           http://${INGRESS_IP}/"
echo "✅  API:           http://${INGRESS_IP}/api/commitments-one"
echo "✅  Headlamp:      http://${HEADLAMP_IP}/"
EOF
