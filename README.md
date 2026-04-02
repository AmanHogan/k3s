# k3s Local Dev Cluster

A 3-node k3s Kubernetes cluster with a full GitOps CI/CD pipeline, running in VirtualBox via Vagrant.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Your Mac                                               │
│  git push → GitHub ──────────────────────────┐         │
└─────────────────────────────────────────────┬┘         │
                                              │           │
                                     Jenkins webhook      │
                                              ▼           │
┌─────────────────────────────────────────────────────────┐
│  VirtualBox VMs (192.168.56.0/24)                       │
│                                                         │
│  jenkins-agent  192.168.56.20                           │
│    • Runs Jenkins builds (docker build / push)          │
│    • Hosts Docker registry on :5001                     │
│    • Pushes image → updates gitops manifest → git push  │
│                          │                              │
│                          ▼ ArgoCD detects manifest diff │
│  k3s-master     192.168.56.10  (+ workers .11, .12)    │
│    • ArgoCD pulls from GitHub, deploys to cluster       │
│    • MetalLB assigns IPs 192.168.56.200–.250            │
└─────────────────────────────────────────────────────────┘
```

| Service | URL                         | Credentials                      |
| ------- | --------------------------- | -------------------------------- |
| ArgoCD  | http://192.168.56.205/      | admin / `3k70S8iChdGzYR2E`       |
| Jenkins | http://192.168.56.20:8080/  | see initial password below         |
| Grafana | http://192.168.56.2xx/      | admin / admin                    |
| App     | http://192.168.56.2xx/      | —                                |

---

## Prerequisites

- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/) (7.1+)

---

## Cluster Setup

```bash
vagrant up
```

Provisions all 4 VMs:

| VM              | IP            | Role                                      |
| --------------- | ------------- | ----------------------------------------- |
| `k3s-master`    | 192.168.56.10 | k3s server, MetalLB, ArgoCD               |
| `k3s-worker1`   | 192.168.56.11 | k3s agent                                 |
| `k3s-worker2`   | 192.168.56.12 | k3s agent                                 |
| `jenkins-agent` | 192.168.56.20 | Jenkins controller + Docker builds + registry :5001 |

After `vagrant up` Jenkins will be running at `http://192.168.56.20:8080`. Get the initial admin password:

### SSH into a node

```bash
vagrant ssh k3s-master
vagrant ssh jenkins-agent
```

---

## CI/CD Pipeline

### How it works

1. Developer pushes code to `https://github.com/AmanHogan/commitment-tracker`
2. Jenkins (running on `192.168.56.20`) polls for new commits and triggers a build
3. Jenkins builds the Docker image and pushes it to the registry on the same VM at `192.168.56.20:5001`
4. Jenkins clones the k3s infra repo, updates the image tag in `gitops/<app>/backend.yaml`, and pushes
5. ArgoCD detects the manifest change and deploys the new image to the cluster

### Jenkins initial setup (one-time after `vagrant up`)

Get the initial admin password:

```bash
vagrant ssh jenkins-agent -c "docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
```

Then go to `http://192.168.56.20:8080` and complete the setup wizard. Install suggested plugins.

### Registry

The Docker registry runs on `jenkins-agent` at `192.168.56.20:5001`. All k3s nodes are pre-configured to pull from it (set in `registries.yaml` during provisioning).

To check the registry contents:

```bash
vagrant ssh jenkins-agent -c "curl -s http://localhost:5001/v2/_catalog"
```

---

## GitOps (ArgoCD)

Kubernetes manifests live in `gitops/`. ArgoCD watches this repo and applies any changes automatically.

```
gitops/
  commitment-tracker/
    backend.yaml    ← Deployment + Service for the API
    frontend.yaml   ← Deployment + Service for the UI
    ingress.yaml    ← Ingress rules
```

To add a new application: see [docs/adding-new-apps.md](docs/adding-new-apps.md).

ArgoCD apps are defined in `apps/` and applied during cluster provisioning.

---

## Monitoring

```bash
./scripts/deploy-monitoring.sh
```

Installs Prometheus, Grafana, and Loki via Helm. Grafana is exposed via MetalLB.

---

## MetalLB

- IP pool: `192.168.56.200–192.168.56.250`
- Mode: Layer 2 (ARP)
- Any `Service` with `type: LoadBalancer` gets an IP automatically

---

## Teardown

```bash
vagrant destroy -f
```
