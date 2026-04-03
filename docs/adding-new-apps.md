# Adding a New Application to the CI/CD Pipeline

This guide walks through connecting a new app to the Jenkins + ArgoCD pipeline so that every `git push` automatically builds, pushes, and deploys it.

---

## Overview of what's needed

| Step | Where                | What                               |
| ---- | -------------------- | ---------------------------------- |
| 1    | App repo             | Add a `Dockerfile`                 |
| 2    | App repo             | Add a `Jenkinsfile`                |
| 3    | k3s repo (`gitops/`) | Add Kubernetes manifests           |
| 4    | k3s repo (`apps/`)   | Add an ArgoCD Application manifest |
| 5    | Jenkins UI           | Create a new pipeline job          |

---

## Step 1 — Add a Dockerfile to the app repo

Place a `Dockerfile` in the directory you want to build. A standard Java (Spring Boot) example:

```dockerfile
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn package -DskipTests -q

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

> Match the Java version to your `pom.xml` `<java.version>` property.

For a Node.js app:

```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json .
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=build /app/dist ./dist
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

---

## Step 2 — Add a Jenkinsfile to the app repo

Create `Jenkinsfile` at the root of the app repo:

```groovy
pipeline {
    agent { label 'docker-agent' }

    environment {
        REGISTRY      = "192.168.56.20:5001"
        IMAGE         = "${REGISTRY}/my-new-app"          // ← change this
        K3S_REPO      = "https://github.com/AmanHogan/k3s.git"
        MANIFEST_FILE = "gitops/my-new-app/backend.yaml"  // ← change this
    }

    stages {

        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Build & Push Image') {
            steps {
                script {
                    env.SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    sh """
                        docker build \
                          -t ${IMAGE}:${SHA} \
                          -t ${IMAGE}:latest \
                          ./path/to/service      // ← directory containing Dockerfile
                        docker push ${IMAGE}:${SHA}
                        docker push ${IMAGE}:latest
                    """
                }
            }
        }

        stage('Update Manifest') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'github-token',
                    usernameVariable: 'GH_USER',
                    passwordVariable: 'GH_TOKEN'
                )]) {
                    sh """
                        rm -rf _k3s
                        git clone https://${GH_USER}:${GH_TOKEN}@github.com/AmanHogan/k3s.git _k3s
                        sed -i 's|image: ${REGISTRY}/my-new-app:.*|image: ${IMAGE}:${SHA}|' \
                            _k3s/${MANIFEST_FILE}
                        cd _k3s
                        git config user.email "jenkins@local"
                        git config user.name  "Jenkins"
                        git add ${MANIFEST_FILE}
                        git diff --cached --quiet || git commit -m "ci: update my-new-app image to ${SHA}"
                        git push
                        cd ..
                        rm -rf _k3s
                    """
                }
            }
        }
    }

    post {
        success { echo "✅ Deployed ${SHA}" }
        failure { echo "❌ Build failed." }
    }
}
```

---

## Step 3 — Add Kubernetes manifests to the k3s repo

Create a folder `gitops/my-new-app/` with at minimum a `deployment.yaml`:

```yaml
# gitops/my-new-app/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-new-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-new-app
  template:
    metadata:
      labels:
        app: my-new-app
    spec:
      containers:
        - name: my-new-app
          image: 192.168.56.20:5001/my-new-app:latest # ← Jenkins will update the tag
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: my-new-app
  namespace: default
spec:
  type: LoadBalancer # MetalLB will assign an external IP
  selector:
    app: my-new-app
  ports:
    - port: 80
      targetPort: 8080
```

> `imagePullPolicy: Always` is required so k3s re-pulls the image even if the tag (e.g. `latest`) hasn't changed.

---

## Step 4 — Add an ArgoCD Application manifest

Create `apps/my-new-app.yaml` in the k3s repo:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-new-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/AmanHogan/k3s.git
    targetRevision: HEAD
    path: gitops/my-new-app
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Apply it to the cluster:

```bash
vagrant ssh k3s-master -- "kubectl apply -f /vagrant/argocd-apps/my-new-app.yaml"
```

ArgoCD will now watch `gitops/my-new-app/` and deploy any changes automatically.

---

## Step 5 — Create a Jenkins pipeline job

1. Go to `http://192.168.56.206:8080` → **New Item**
2. Name: `my-new-app`, type: **Pipeline** → OK
3. Under **Pipeline**:
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/AmanHogan/my-new-app.git`
   - Credentials: `github-token`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
4. Save → **Build Now** to test

---

## Checklist

- [ ] `Dockerfile` added to app repo
- [ ] `Jenkinsfile` added to app repo (with correct `IMAGE` and `MANIFEST_FILE`)
- [ ] `gitops/my-new-app/` manifests added to k3s repo with `image: 192.168.56.20:5001/my-new-app:latest`
- [ ] `apps/my-new-app.yaml` applied to cluster
- [ ] Jenkins job created pointing at the app repo
- [ ] First build triggered successfully
