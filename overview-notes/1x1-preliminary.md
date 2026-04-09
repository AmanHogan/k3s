# Learning Notes

## Infrastructure

### Tools Learned

- **Minikube** — local single-node K8s cluster for hands-on fundamentals (nginx, MongoDB stack, Redis, NFS, PVs, StatefulSets)
- **k3s** — lightweight K8s; built a 3-node cluster (1 master + 2 workers) via Vagrant + VirtualBox
- **Vagrant** — VM lifecycle management for the k3s cluster (Vagrantfile, provisioning scripts)
- **VirtualBox** — hypervisor for the k3s VMs
- **Docker** — containerization; multi-stage Dockerfiles for Spring Boot and Next.js; local registry at 192.168.56.20:5001
- **MetalLB** — load balancer for bare-metal K8s, Layer 2 mode; resolved klipper-lb conflict with --disable servicelb
- **Traefik** — ingress controller (built into k3s); routes /api → Spring Boot and / → Next.js frontend
- **Jenkins** — CI server; builds Docker images, pushes to local registry, updates manifest SHA tag, triggers ArgoCD sync
- **ArgoCD** — GitOps continuous delivery; watches k3s repo for manifest changes, auto-deploys to cluster
- **Helm** — K8s package manager; used for kube-prometheus-stack, Loki, Headlamp installs
- **Prometheus** — metrics collection and alerting
- **Grafana** — metrics + log visualization dashboards (integrated with Prometheus and Loki)
- **Loki** — log aggregation for the k3s cluster
- **Headlamp** — web-based Kubernetes dashboard

## Coding Development

### Spring Boot / Java

- **Spring Data JPA + Hibernate** — ORM stack; entities, repositories, service/controller layers, JPA auditing (@CreatedDate / @LastModifiedDate), lazy vs eager loading
- **Spring Data MongoDB** — document model with @Document, MongoRepository, @EnableMongoAuditing
- **Lombok** — @Data, @Builder, @NoArgsConstructor, @AllArgsConstructor, @RequiredArgsConstructor for boilerplate reduction
- **Jakarta Persistence (JPA)** — @Entity, @Table, @Id, @GeneratedValue, @OneToMany, @ManyToOne, @JoinColumn, @JsonIgnore
- **Spring AI MCP** — built MCP server using spring-ai-mcp-server-webflux-spring-boot-starter; @Tool annotation, WebFlux SSE + STDIO transports

### Frontend

- **Next.js (App Router)** — full-stack React framework; server components, server actions, dynamic routes
- **TypeScript** — typed frontend throughout
- **shadcn/ui + Tailwind CSS + Radix UI** — component library and styling
- **Zod** — schema validation for DTOs/forms

### Databases

- **PostgreSQL** — relational DB for commitment tracker (Spring Data JPA, ddl-auto=validate, manual SQL migrations)
- **MongoDB** — document DB experience via Spring Data MongoDB

## Extra

- **PlantUML** — architecture and sequence diagramming (in progress: Jenkins ↔ ArgoCD pipeline diagram)
- **Draw.io / Diagramming** — system/infrastructure diagrams

## BP Work

### SIM Intake & Carrier App Form Improvements

> Pre-filled for Business Commitments entry:

- **Work Item:** SIM Intake and Carrier App Form Improvements (@mvnx/sims-and-devices)
- **Application Context:** MVNX SIM Intake portal — self-service forms used by AT&T Vendors for SIM provisioning and Carrier App registration
- **Description:** Updated the SIM Intake and Carrier App forms with terminology improvements, field simplifications, and separated the Carrier App into a standalone self-service form with dedicated email routing.
- **Problem:** Terminology in the existing forms was inconsistent and outdated (e.g. non-standard SIM terms). Carrier App registration was embedded inside the SIM Intake flow, causing confusion and routing all submissions to the same email regardless of form type. Vendors could not independently access or submit the Carrier App form.
- **Who Benefited:** AT&T Vendors submitting SIM intake requests and Carrier App registrations; Marilyn's team who receives Carrier App submissions separately
- **Impact:** Cleaner, more accurate form terminology reduces vendor confusion. Separating Carrier App into a standalone self-service form streamlines the submission process and ensures Carrier App emails route directly to the correct recipient (SIM_CARRIER_APP_EMAIL_RECIPIENTS) rather than the general SIM intake inbox. Route-specific email recipient configuration makes future routing changes low-risk.
- **Alignment:** Developer productivity / self-service tooling improvement; reduces manual triage of misdirected form submissions
- **Status Notes:** Completed — changes include terminology updates (SM-DS, SM-DP+, QR Code), field simplifications (removed SIM Vendor Select, simplified artwork request, renamed form to AT&T SIM Intake Form), added Yes/No Carrier App checkbox to intake form, created standalone Carrier App form with dedicated API endpoint (/api/sims/carrier-app) and CarrierAppApprovalFormClient component integrated into Self-Service sidebar
- **Value Entries:**
  - Terminology accuracy: Updated SIM-related labels to industry-standard terms (SM-DS, SM-DP+, QR Code)
  - Form simplification: Removed irrelevant fields (SIM Vendor Select, SIM provider & contact) reducing vendor friction
  - Separation of concerns: Carrier App moved to standalone form with its own API route and email recipients
  - Email routing: Route-specific recipient env vars (SIM_INTAKE, SIM_ORDER, SIM_CARRIER_APP) enable precise delivery

## Innovation

Signed up for AskData Hackathon

## Leadership

Interviewed and got position as national system tech circle lead
Circle lead for inspireAsian with Pavan
