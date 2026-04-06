#!/bin/bash
# install-cicd.sh — install ArgoCD into the running k3s cluster
# Run this once manually after 'vagrant up'.
#
# NOTE: Jenkins runs directly on the jenkins-agent VM (192.168.56.20:8080),
# provisioned by jenkins-agent.sh. It is NOT installed into k3s.
#
# After this script completes, apply the ArgoCD Application CRs to wire up GitOps:
#   vagrant ssh k3s-master -c 'kubectl apply -f /vagrant/argocd-apps/'
#
# ArgoCD will then auto-sync these paths from Git on every push:
#   argocd-apps/commitment-tracker.yaml  →  manifests/commitment-tracker/
set -e

echo ">>> Installing ArgoCD..."
vagrant ssh k3s-master -- bash -s << 'EOF'
kubectl create namespace argocd 2>/dev/null || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"LoadBalancer"}}'
echo "ArgoCD applied. Pods will come up as images pull."
EOF

echo ""
echo ">>> Waiting for ArgoCD to get an external IP..."
vagrant ssh k3s-master -- bash -s << 'EOF'
wait_for_ip() {
  local ns=$1 svc=$2
  for i in $(seq 1 60); do
    IP=$(kubectl get svc "$svc" -n "$ns" \
      -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
    [ -n "$IP" ] && echo "$IP" && return
    sleep 5
  done
  echo "<pending>"
}

echo "Waiting for ArgoCD..."
ARGO_IP=$(wait_for_ip argocd argocd-server)
ARGO_PASS=$(kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || echo "<not ready yet>")

echo ""
echo "✅  ArgoCD UI:   http://${ARGO_IP}/"
echo "    Login:       admin / ${ARGO_PASS}"
echo ""
echo "✅  Jenkins UI:  http://192.168.56.20:8080/"
echo "    Login:       admin / admin"
echo "    (Jenkins runs on the jenkins-agent VM — change password after first login)"
EOF
