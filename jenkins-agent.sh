#!/bin/bash
# jenkins-agent.sh — provision the Jenkins build agent VM
# This VM connects to the Jenkins controller running in k3s as a permanent agent.
set -e

echo 'vagrant ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vagrant

# ── Install Docker ───────────────────────────────────────────────────────────
apt-get update -q
apt-get install -y -q ca-certificates curl gnupg

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -q
apt-get install -y -q docker-ce docker-ce-cli containerd.io

# Allow vagrant user to run docker without sudo
usermod -aG docker vagrant

# ── Configure Docker to trust the local registry (this VM hosts it) ─────────
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "insecure-registries": ["192.168.56.20:5001"]
}
EOF
systemctl restart docker

# ── Start the local Docker registry on port 5001 ────────────────────────────
docker run -d \
  --name registry \
  --restart=always \
  -p 5001:5000 \
  -v /var/lib/registry:/var/lib/registry \
  registry:2

echo "Registry running at 192.168.56.20:5001"

# ── Install Java (required for Jenkins agent process) ───────────────────────
apt-get install -y -q openjdk-17-jre-headless

# ── Install git ──────────────────────────────────────────────────────────────
apt-get install -y -q git

echo "Jenkins agent VM ready — registry at 192.168.56.20:5001"
