# ArgoCD

Place ArgoCD install manifest and Application CRDs here.

Suggested layout:

- `install.yaml` — ArgoCD namespace + install (from upstream)
- `ingress.yaml` — Traefik Ingress for ArgoCD UI
- `app-commitment-tracker.yaml` — ArgoCD Application pointing at gitops/commitment-tracker/
- `app-monitoring.yaml` — ArgoCD Application pointing at platform/monitoring/
- `app-jenkins.yaml` — ArgoCD Application pointing at gitops/jenkins/

Install ArgoCD:

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
