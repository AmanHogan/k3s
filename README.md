# k3s Local Dev Cluster

A 3-node K3s Kubernetes cluster (1 master, 2 workers) running in VirtualBox via Vagrant on Apple Silicon (ARM64).

## Prerequisites

- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/) (7.1+ with ARM support)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (for building images and running the local registry)

---

## Cluster Setup

```bash
vagrant up
```

This provisions:
- `k3s-master` at `192.168.56.10` — runs K3s server + MetalLB
- `k3s-worker1` at `192.168.56.11` — runs K3s agent
- `k3s-worker2` at `192.168.56.12` — runs K3s agent

MetalLB is installed automatically on the master and assigns IPs from `192.168.56.200–192.168.56.250` to `LoadBalancer` services.

### SSH into a node

```bash
vagrant ssh k3s-master
vagrant ssh k3s-worker1
vagrant ssh k3s-worker2
```

---

## Local Docker Registry

All nodes are pre-configured to pull from a registry running on your Mac at `192.168.56.1:5000`.

### Start the registry (one-time)

```bash
docker run -d -p 5001:5000 --restart=always --name registry registry:2
```

### Build and push an image

```bash
docker build -t 192.168.56.1:5001/myapp:latest ./my-app
docker push 192.168.56.1:5001/myapp:latest
```

Reference it in Kubernetes as:
```yaml
image: 192.168.56.1:5001/myapp:latest
imagePullPolicy: Always
```

### After updating your image, rolling restart

```bash
docker build -t 192.168.56.1:5001/myapp:latest . && docker push 192.168.56.1:5001/myapp:latest
kubectl rollout restart deployment/myapp
```

---

## Test Hello-World App

A minimal nginx hello-world is included to verify the full stack works.

```bash
./test-app/test-deploy.sh
```

This will:
1. Start the local registry (if not running)
2. Build `test-app/Dockerfile`
3. Push to `192.168.56.1:5001/hello-k3s:latest`
4. Apply `test-app/k8s.yaml` (Deployment + LoadBalancer Service)
5. Print the MetalLB-assigned IP to curl

```bash
curl http://192.168.56.200   # or whichever IP MetalLB assigns
```

---

## MetalLB

Installed automatically during `vagrant up`. Config is in `metallb/metallb.yaml`.

- IP pool: `192.168.56.200–192.168.56.250`
- Mode: Layer 2 (ARP)
- Any `Service` with `type: LoadBalancer` gets an IP from this pool automatically.

---

## Cluster Commands (from master node)

```bash
kubectl get nodes           # check all 3 nodes are Ready
kubectl get pods -A         # all pods across all namespaces
kubectl get svc             # list services and their external IPs
```

---

## Teardown

```bash
vagrant destroy -f
```
