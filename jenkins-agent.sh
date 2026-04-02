#!/bin/bash
# jenkins-agent.sh — provision the Jenkins VM
# Runs the Jenkins controller, Docker build agent, and image registry all-in-one.
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

# ── Install git ──────────────────────────────────────────────────────────────
apt-get install -y -q git

# ── Start Jenkins controller in Docker ───────────────────────────────────────
# Runs as root so it can use the Docker socket directly (homelab only).
# All build steps run inside this container — no separate agent node needed.
docker run -d \
  --name jenkins \
  --restart=always \
  -p 8080:8080 \
  -p 50000:50000 \
  -u root \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/bin/docker:/usr/bin/docker \
  jenkins/jenkins:lts-jdk17

echo "Jenkins controller running at http://192.168.56.20:8080"
echo "Registry running at 192.168.56.20:5001"
echo ""
echo "Initial admin password (wait ~60s for Jenkins to start):"
echo "  docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
