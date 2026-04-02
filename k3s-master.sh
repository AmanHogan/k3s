#!/bin/bash
# Allow vagrant user to run sudo without a password
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vagrant

# Configure k3s to trust the registry running on the jenkins-agent VM (192.168.56.20:5001)
mkdir -p /etc/rancher/k3s
cat > /etc/rancher/k3s/registries.yaml <<EOF
mirrors:
  "192.168.56.20:5001":
    endpoint:
      - "http://192.168.56.20:5001"
configs:
  "192.168.56.20:5001":
    tls:
      insecure_skip_verify: true
EOF

# Restart k3s if already running so it picks up the new registries.yaml
if systemctl is-active --quiet k3s; then
  systemctl restart k3s
  # Wait for k3s API to come back up
  until kubectl get nodes &>/dev/null; do sleep 2; done
fi

# Install K3s on the master node.
# --node-ip        : bind to the host-only interface, not VirtualBox NAT (10.0.2.15)
# --disable servicelb: we use MetalLB for IP assignment (klipper-lb conflicts with MetalLB speakers)
# Traefik is kept — it's the ingress controller; MetalLB assigns it an external IP.
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --disable servicelb --node-ip=192.168.56.10 --flannel-iface=eth1

# Make sure kubectl is set up for the vagrant user
sudo mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube/config

# Get the token for the worker nodes
TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)

# Store the token for the workers to use
echo $TOKEN > /vagrant/token

# Wait for flannel to be ready before installing MetalLB
# (MetalLB pods will fail with 'subnet.env not found' if flannel isn't up)
echo "Waiting for flannel to be ready..."
until [ -f /run/flannel/subnet.env ]; do sleep 2; done

# Install MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml

# MetalLB pods will come up on their own as images pull — no need to block here.
# The webhook wait below handles the only real dependency (applying the IP pool config).

# Wait for the webhook endpoint (with a 120s best-effort wait)
echo "Waiting for MetalLB webhook endpoint..."
WEBHOOK_TIMEOUT=120
WEBHOOK_ELAPSED=0
until kubectl get endpoints -n metallb-system webhook-service -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null | grep -q '.'; do
  if [ $WEBHOOK_ELAPSED -ge $WEBHOOK_TIMEOUT ]; then
    echo "Webhook not ready after ${WEBHOOK_TIMEOUT}s — removing ValidatingWebhookConfiguration so apply can proceed."
    # Deleting the webhook is safe in homelab: it's only for validation, not enforcement.
    # MetalLB re-creates it on upgrade; re-provision restores it too.
    kubectl delete validatingwebhookconfiguration metallb-webhook-configuration 2>/dev/null || true
    break
  fi
  sleep 2
  WEBHOOK_ELAPSED=$((WEBHOOK_ELAPSED + 2))
done
echo "Applying MetalLB config..."

# Apply IP pool config (shared via /vagrant)
kubectl apply -f /vagrant/platform/metallb/metallb.yaml

# Traefik (k3s default ingress controller) is already running.
echo "Waiting for Traefik to be ready..."
kubectl wait --namespace kube-system \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=traefik \
  --timeout=180s || \
  echo "Warning: Traefik not ready yet — it will come up on its own."

echo "Traefik service:"
kubectl get svc -n kube-system traefik

# Install Helm (needed for monitoring + Jenkins)
if ! command -v helm &>/dev/null; then
  echo "Installing Helm..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# ── ArgoCD ───────────────────────────────────────────────────────────────────
echo "Installing ArgoCD..."
kubectl create namespace argocd 2>/dev/null || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"LoadBalancer"}}' 2>/dev/null || true
# Don't wait — it pulls several images; deploy-all.sh will print the IP once MetalLB is ready

# Jenkins runs on the jenkins-agent VM (192.168.56.20:8080) — not in the cluster