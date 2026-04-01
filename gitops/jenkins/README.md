# Jenkins

Place Jenkins K8s manifests here (Deployment, Service, PVC, Ingress).

Suggested layout:

- `jenkins.yaml` — Deployment + Service + PVC
- `ingress.yaml` — Traefik Ingress rule for /jenkins
- `rbac.yaml` — ServiceAccount + ClusterRoleBinding for Jenkins to call kubectl

Quick start with Helm:

```bash
helm repo add jenkins https://charts.jenkins.io
helm upgrade --install jenkins jenkins/jenkins \
  --namespace jenkins --create-namespace \
  --values values.yaml
```
