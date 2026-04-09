---

**Project Summary**
- **Purpose:** Backend for a Commitment Tracker — stores and exposes business & development commitments, events (with sub‑events), learning modules and action items via a REST API.
- **High‑level:** Spring Boot app using Spring Data JPA + PostgreSQL; frontend talks to clean DTO APIs so UI can CRUD and lazy‑load related data.

**Top Spring / Spring‑JPA points I learned**
- **Dependency Injection / Beans:** Use constructor injection and annotations like `@Service`, `@Repository`, `@RestController` to wire responsibilities and make components testable.
- **REST controllers:** Build HTTP APIs with `@GetMapping`/`@PostMapping`/`@PutMapping`/`@DeleteMapping`, accept `@RequestBody` DTOs and return `ResponseEntity` with proper status codes.
- **DTOs & mapping:** Never return JPA entities directly; use `record` DTOs and mappers to avoid circular JSON, control shape, and separate API from persistence.
- **JPA entities & relationships:** Model domain with `@Entity`, `@Table`, `@OneToMany` / `@ManyToOne`; understand owning side, `cascade` and `orphanRemoval` effects on lifecycle.
- **Persistence context & updates:** Hibernate’s dirty‑checking and persistence context mean changes to managed entities are flushed automatically; `save()` can insert or update depending on identity.
- **Repository pattern:** `JpaRepository` provides `findAll()`, `findById()`, `save()`, `deleteById()` and simplifies data access without boilerplate.
- **Schema management:** `spring.jpa.hibernate.ddl-auto=validate` requires manual DB migrations (or add Flyway/Liquibase); schema mismatches fail app startup — learned to apply `CREATE/ALTER` carefully.
- **Config & dev workflow:** application.properties controls datasource and JPA; `spring-boot-devtools` helps during development but can cause stale classloader issues that require clean builds.
---

**Project Summary**

Built a fully self-hosted homelab Kubernetes platform from scratch using Vagrant-provisioned VMs running k3s, with a complete GitOps CI/CD pipeline and observability stack — all running locally on a personal machine.

---

**What I Learned (up to 8 bullets)**

- **Infrastructure as Code / Virtualization (Vagrant):** Provisioned and managed multiple Linux VMs declaratively using Vagrantfile and shell scripts; learned how host-only networking, static IPs, and VM lifecycle work in a multi-node cluster setup.

- **Kubernetes & k3s:** Deployed and operated a multi-node Kubernetes cluster (master + workers) using k3s; learned core concepts — namespaces, Deployments, Services, StatefulSets, Ingress, ConfigMaps, Secrets, init containers, and rolling updates.

- **Networking:** Configured host-only VM networking, DNS (CoreDNS), Ingress routing via Traefik, and private Docker registry access across VMs using custom `registries.yaml` trust configurations.

- **GitOps & ArgoCD:** Implemented a GitOps workflow where cluster state is driven entirely by a Git repo; ArgoCD watches the infra repo and automatically syncs manifest changes to the cluster, including namespace creation and resource pruning.

- **CI/CD with Jenkins:** Set up a Jenkins pipeline (polling-based, no webhook) that detects commits, builds Docker images, pushes to a private registry, and automatically updates Kubernetes manifests in the infra repo to trigger ArgoCD deploys.

- **Observability — Prometheus & Grafana:** Deployed a monitoring stack with Prometheus scraping cluster metrics and Grafana dashboards for visualization; learned how scrape configs, service discovery, and alerting rules work in a Kubernetes environment.

- **Log Aggregation — Loki:** Integrated Loki as a log aggregation backend with Grafana as the query UI; learned how log streams, label selectors, and LogQL queries work compared to metrics-based monitoring.

- **Container Registry & Image Management:** Operated a private Docker registry inside the homelab; learned how image tagging strategies (SHA-based tags), registry trust configuration, and image pull policies work in a Kubernetes cluster.

---

**Project Summary — `k3s-mcp`**

A small tooling/repo layer that manages your local k3s homelab lifecycle and developer workflows (VM provisioning, cluster bootstrapping, and helper scripts) so you can reproduce, test, and extend the cluster locally.

**What it does (high level)**

- Provides Vagrant provisioning and shell scripts to create and configure the k3s master and worker VMs.
- Installs and configures k3s on the VMs (master + agents) and writes cluster bootstrap files (`registries.yaml`, CoreDNS patches, etc.).
- Manages local registry/trust configuration so nodes can pull images from your homelab registry.
- Contains helper scripts for common ops: deploy-all, cluster repair, ArgoCD/Traefik fixes, and pushing images/manifests.
- Holds opinionated manifests and provisioning snippets used by ArgoCD and CI (links infra with CI jobs).

**Learning outcomes / What you learned (up to 8 bullets)**

- **VM provisioning with Vagrant:** how to script multi-node VMs, map networking (host-only), and reproduce environment reliably.
- **Cluster bootstrap automation:** how to automate k3s install/config (systemd services, registries.yaml) so cluster nodes are identical and registry-trusted.
- **Local registry patterns:** running and exposing a registry inside a VM, and making k3s nodes and host resolve/pull images reliably.
- **Configuration drift & GitOps interplay:** how to keep manifests in a repo (ArgoCD) and use provisioning scripts to align live cluster state with the repo.
- **Troubleshooting cluster networking/DNS:** diagnosing CoreDNS/Traefik issues in a VirtualBox/Vagrant environment and applying persistent fixes.
- **Scripting idempotent ops:** writing scripts that can re-run safely (apply patch only if missing, restart deployments cleanly).
- **CI/deploy integration:** bridging Jenkins builds to infra (image tag updates in `k3s` repo) and understanding the end-to-end flow.
- **Operational tradeoffs:** learned limitations of running controller+agent on the same VM, restart/resiliency implications, and when to separate concerns.

**Tools involved / surface list**

- `Vagrant`, `VirtualBox` (VM lifecycle and networking)
- Shell scripting (provisioners: k3s-master.sh, k3s-worker.sh, `deploy-all.sh`)
- `k3s` (lightweight Kubernetes) and `kubectl`
- `Docker` / local registry (`registry:2`)
- `ArgoCD` (GitOps) and `Helm` (where used)
- Observability tooling referenced in repo: `Prometheus`, `Grafana`, `Loki`, `Traefik`
- `git` / GitHub for manifest-driven deployment and CI integration

---
