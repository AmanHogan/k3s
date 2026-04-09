# 1-on-1 Prep Todo

## Must Finish Before 1-on-1

- [ ] **Diagram: Jenkins ↔ ArgoCD pipeline** — how they communicate, who owns what step (git push → Jenkins build → registry push → manifest update → ArgoCD detects → deploys). Use PlantUML or draw.io.
- [ ] Update 1x1-preliminary.md with complete technology list (see below)

## Topics to Cover in 1-on-1

### Infrastructure

- Summarize: built a 3-node k3s cluster (Vagrant + VirtualBox), full GitOps CI/CD pipeline with Jenkins + ArgoCD
- Highlight: MetalLB, Traefik ingress, Prometheus + Grafana + Loki monitoring stack, Headlamp dashboard
- In progress: wiring up full end-to-end auto-deploy (Jenkinsfile + ArgoCD Application CRs)

### Coding Development

- Spring Data JPA: entities, repositories, service/controller layers, auditing, lazy-load fix
- Spring Data MongoDB: document model, MongoRepository, auditing
- Spring AI MCP: built MCP server with @Tool annotations, WebFlux SSE transport
- Full-stack Next.js + Spring Boot commitment tracker app

### BP Work

- (Fill in with partner-specific items)

### Innovation

- Signed up for AskData Hackathon

### Leadership

- Interviewed and got position as national system tech circle lead
- Circle lead for inspireAsian with Pavan

### Extra / Learning

- PlantUML and architecture diagramming
- Kubernetes fundamentals (Minikube hands-on: nginx, MongoDB stack, Redis, NFS, PVs, StatefulSets)
