#!/bin/bash
set -e

REGISTRY="192.168.56.1:5001"
PUSH_REGISTRY="localhost:5001"
IMAGE_NAME="hello-k3s:latest"

echo "==> Starting local registry (if not already running)..."
if ! docker ps --format '{{.Names}}' | grep -q '^registry$'; then
  docker run -d -p 5001:5000 --restart=always --name registry registry:2
  echo "    Registry started."
else
  echo "    Registry already running."
fi

echo "==> Building image..."
docker build -t "$PUSH_REGISTRY/$IMAGE_NAME" "$(dirname "$0")"

echo "==> Pushing image to local registry..."
docker push "$PUSH_REGISTRY/$IMAGE_NAME"

echo "==> Applying Kubernetes manifests..."
vagrant ssh k3s-master -- bash << 'EOF'
kubectl apply -f /vagrant/test-app/k8s.yaml
kubectl rollout status deployment/hello-k3s --timeout=60s
kubectl get svc hello-k3s
EOF

echo ""
echo "Done! Test with:"
echo "  curl http://$(vagrant ssh k3s-master -c 'kubectl get svc hello-k3s -o jsonpath={.status.loadBalancer.ingress[0].ip}' 2>/dev/null)"

vagrant ssh k3s-master -c 'kubectl rollout restart deployment/hello-k3s'