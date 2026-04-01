# ArgoCD Application CRDs

This folder holds ArgoCD `Application` resources — the "index" of what ArgoCD manages.
Each file points ArgoCD at a path inside this repo.

Example:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: commitment-tracker
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/amanhogan/k3s
    targetRevision: HEAD
    path: gitops/commitment-tracker
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```
