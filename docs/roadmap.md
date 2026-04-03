# Roadmap / TODO

## In Progress

- [ ] Wire up ArgoCD fully — apply `argocd-apps/` CRs so ArgoCD auto-syncs on git push
- [ ] Write a Jenkinsfile in the commitment-tracker app repo that builds, pushes image, and updates `manifests/commitment-tracker/spring-commitment-tracker.yaml` with the new git SHA tag

## Completed

- [x] 3-node k3s cluster (master + 2 workers) via Vagrant/VirtualBox
- [x] MetalLB (Layer 2, pool 192.168.56.200–250)
- [x] Traefik ingress with routing (`/api` → Spring Boot, `/` → React)
- [x] MongoDB + Mongo Express
- [x] Commitment Tracker API (Spring Boot) + Frontend (React)
- [x] Headlamp k8s dashboard
- [x] Prometheus + Grafana + Loki monitoring stack
- [x] Jenkins installed (192.168.56.20:8080)
- [x] ArgoCD installed (LoadBalancer IP, see README for credentials)
- [x] GitOps folder structure (`argocd-apps/` + `manifests/`)

## Known Issues / Notes

| Problem                       | Root Cause                                                                                                               | Fix                                                                                          |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------- |
| MetalLB speakers crashing     | k3s built-in servicelb (klipper-lb) competed for the same ports                                                          | Disabled servicelb via `--disable servicelb` flag                                            |
| All nodes showing `10.0.2.15` | k3s binding to VirtualBox NAT interface instead of host-only                                                             | Added `--node-ip` and `--flannel-iface=eth1` to k3s install                                  |
| ingress-nginx crash loop      | Conflicted with Traefik; port conflict                                                                                   | Removed ingress-nginx; Traefik is the right choice for k3s                                   |
| Grafana CrashLoopBackOff      | kube-prometheus-stack v82+ and loki-stack both set `isDefault: true` on datasource ConfigMaps; Grafana 12.x rejects this | Patch loki ConfigMap to `isDefault: false` after install (baked into `deploy-monitoring.sh`) |
| Helm release stuck            | Aborted install leaves pending-install lock                                                                              | `helm uninstall` + delete orphaned secrets (see `scripts/commands`)                          |
