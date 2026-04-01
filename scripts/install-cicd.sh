#!/bin/bash
# install-cicd.sh — install ArgoCD and Jenkins into the running k3s cluster
# Run this once manually. Future 'vagrant up' will do it automatically via k3s-master.sh.
set -e

echo ">>> Installing ArgoCD..."
vagrant ssh k3s-master -- bash -s << 'EOF'
kubectl create namespace argocd 2>/dev/null || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"LoadBalancer"}}'
echo "ArgoCD applied. Pods will come up as images pull."
EOF

echo ""
echo ">>> Installing Jenkins..."
vagrant ssh k3s-master -- bash -s << 'EOF'
helm repo add jenkins https://charts.jenkins.io 2>/dev/null || true
helm repo update
helm upgrade --install jenkins jenkins/jenkins \
  --namespace jenkins --create-namespace \
  --values /vagrant/platform/jenkins/values.yaml \
  --timeout 10m \
  --wait || echo "Warning: Jenkins install timed out — pods will finish pulling images on their own."
EOF

echo ""
echo ">>> Waiting for ArgoCD and Jenkins to get external IPs..."
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

echo "Waiting for Jenkins..."
JENKINS_IP=$(wait_for_ip jenkins jenkins)
JENKINS_PASS=$(kubectl get secret jenkins -n jenkins \
  -o jsonpath='{.data.jenkins-admin-password}' 2>/dev/null | base64 -d || echo "<not ready yet>")

echo ""
echo "✅  ArgoCD UI:   http://${ARGO_IP}/"
echo "    Login:       admin / ${ARGO_PASS}"
echo ""
echo "✅  Jenkins UI:  http://${JENKINS_IP}:8080/"
echo "    Login:       admin / ${JENKINS_PASS}"
EOF
