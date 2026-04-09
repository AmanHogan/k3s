# Infrastructure Learning Todo

## Kubernetes Fundamentals (kubernetes-notes/)

- [ ] Review Pod, Deployment, Service, ConfigMap, Secret manifest structure
- [ ] Review Ingress and IngressController concepts
- [ ] Review NFS setup and StorageClass (04-nfs-setup/)
- [ ] Review PersistentVolumes and PersistentVolumeClaims (05-persistent-volumes/)
- [ ] Review StatefulSets and when to use them vs Deployments (06-statefulsets/)
- [ ] Understand MetalLB Layer 2 mode and how IPs are allocated
- [ ] Understand the difference between ClusterIP / NodePort / LoadBalancer

## k3s Cluster (k3s/)

- [ ] Re-trace full cluster bootstrap: Vagrantfile → k3s-master.sh → k3s-worker.sh
- [ ] Understand how MetalLB replaced klipper-lb (--disable servicelb flag, why it was needed)
- [ ] Understand how Traefik replaces ingress-nginx in k3s and how routing rules work
- [ ] Review the manifest files for commitment-tracker (ingress, postgres, spring, react)

## CI/CD Pipeline (k3s/ Jenkins + ArgoCD)

- [ ] Trace the full pipeline flow: git push → Jenkins → docker build → registry → manifest update → ArgoCD → deploy
- [ ] Complete the Jenkinsfile in commitment-tracker that builds, pushes, and updates the SHA tag in the manifest
- [ ] Wire up the ArgoCD Application CRs in argocd-apps/ so auto-sync activates on manifest change
- [ ] Understand how Jenkins polls vs. webhook triggers work
- [ ] **Diagram: Jenkins ↔ ArgoCD communication** (how they handoff, what each is responsible for) ← IN PROGRESS
- [ ] Understand ArgoCD Application CRD structure (source, destination, syncPolicy)

## Monitoring (k3s/platform/monitoring/)

- [ ] Review kube-prometheus-stack components: Prometheus, Alertmanager, Grafana
- [ ] Review Loki log aggregation and how it connects to Grafana
- [ ] Understand the Grafana datasource ConfigMap conflict fix (isDefault: false patch in deploy-monitoring.sh)
- [ ] Know what dashboards are available by default from kube-prometheus-stack

## Docker

- [ ] Review multi-stage Dockerfile pattern (Maven build → JRE runtime for Spring Boot)
- [ ] Review multi-stage Dockerfile pattern (Node build → Node runtime for Next.js)
- [ ] Understand how the local Docker registry at 192.168.56.20:5001 works (plain HTTP, insecure-registries)

## Spring AI MCP (k3s-mcp/)

- [ ] Review the MCP server sample (WebFlux SSE + STDIO transports)
- [ ] Understand @Tool annotation registration in Spring AI
- [ ] Understand SSE vs STDIO transport difference and when to use each
- [ ] Review integration tests in k3s-mcp/integration-tests/

## Tooling / Concepts to Know

- [ ] Vagrant: `vagrant up`, `vagrant ssh <vm>`, `vagrant halt`, `vagrant destroy`
- [ ] Helm: install/upgrade/uninstall, values override, how to fix pending-install lock
- [ ] kubectl: rollout commands, label selectors, port-forward, logs, exec
- [ ] PlantUML / Diagramming: create architecture diagrams for the full CI/CD + cluster setup
