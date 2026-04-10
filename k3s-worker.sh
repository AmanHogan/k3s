#!/bin/bash
# Allow vagrant user to run sudo without a password
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vagrant

# Get the master node's IP from the arguments
MASTER_IP=$1

# Get the token from the shared folder
TOKEN=$(cat /vagrant/token)

# Configure k3s to trust the registry running on the Jenkins agent VM (192.168.56.20:5001)
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

# Restart k3s-agent if already running so it picks up the new registries.yaml
if systemctl is-active --quiet k3s-agent; then
  systemctl restart k3s-agent
fi

# Install K3s agent (worker) and join the master node.
# NODE_IP: use the host-only interface IP so kubelet registers on 192.168.56.x, not VirtualBox NAT
NODE_IP=$(ip -4 addr show eth1 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || \
          ip -4 addr show enp0s8 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$TOKEN sh -s - --node-ip=$NODE_IP --flannel-iface=eth1