# Deploy to Local Kubernetes Cluster via GitLab CI/CD

This guide explains how to deploy your fraud detection services to a **local Kubernetes cluster** (Docker Desktop K8s or any local K8s) using GitLab CI/CD pipeline.

---

## Prerequisites

### 1. Kubernetes Cluster Running Locally

**Option A: Docker Desktop (Windows/macOS)**
- Install Docker Desktop
- Enable Kubernetes: **Settings > Kubernetes > Enable Kubernetes**
- Wait for it to be ready (green indicator)

**Option B: Minikube**
```bash
minikube start --cpus=4 --memory=8192 --disk-size=50g
```

**Option C: kind (Kubernetes in Docker)**
```bash
kind create cluster --name fraud-detection
```

### 2. Verify Kubernetes is Running
```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes

# Should show something like:
# NAME             STATUS   ROLES    ...
# docker-desktop   Ready    control-plane,master ...
```

### 3. GitLab Runner with Kubernetes Support
- Runner must have **kubectl** access to your cluster
- Can be shell executor with kubectl installed, or Docker executor

---

## Step 1: Export Kubeconfig

Your `kubeconfig` file contains credentials to access the Kubernetes cluster. You need to encode it as a GitLab CI variable.

**On Windows (PowerShell):**
```powershell
# Path to kubeconfig (usually ~/.kube/config)
$KubeconfigPath = "$env:USERPROFILE\.kube\config"

# Read and base64-encode
$KubeconfigContent = Get-Content -Path $KubeconfigPath -Raw
$KubeconfigBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($KubeconfigContent))

# Copy to clipboard
$KubeconfigBase64 | Set-Clipboard

Write-Host "✓ Kubeconfig (base64) copied to clipboard"
Write-Host "Length: $($KubeconfigBase64.Length) characters"
```

**On macOS/Linux:**
```bash
# Encode kubeconfig
cat ~/.kube/config | base64 | pbcopy  # macOS
cat ~/.kube/config | base64 | xclip -selection clipboard  # Linux

echo "✓ Kubeconfig (base64) copied to clipboard"
```

---

## Step 2: Add KUBE_CONFIG to GitLab

1. Go to **Project > Settings > CI/CD > Variables**
2. Click **Add variable**
3. Set:
   - **Key:** `KUBE_CONFIG`
   - **Value:** Paste the base64-encoded kubeconfig from above
   - **Protect variable:** ✓ (recommended)
   - **Mask variable:** ✓ (recommended for security)
4. Click **Add variable**

---

## Step 3: Verify K8s Manifests Exist

Ensure you have Kubernetes manifest files in the `k8s/` directory:

```
k8s/
├── namespace.yaml
├── configmap.yaml
├── secrets.yaml
├── auth-service-deployment.yaml
├── transaction-service-deployment.yaml
├── fraud-detection-service-deployment.yaml
├── ingress.yaml
└── README.md
```

**Check manifest requirements:**
- Each manifest must have `image: IMAGE_REGISTRY/service-name:latest` (placeholder)
- The pipeline will replace `IMAGE_REGISTRY` with `$CI_REGISTRY_IMAGE`
- Services must be in `fraud-detection` namespace

---

## Step 4: Prepare K8s Manifests (Example)

If you don't have manifests yet, here's a minimal example for `auth-service`:

**k8s/auth-service-deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth-service
  namespace: fraud-detection
  labels:
    app: auth-service
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: auth-service
  template:
    metadata:
      labels:
        app: auth-service
        version: v1
    spec:
      containers:
      - name: auth-service
        image: IMAGE_REGISTRY/auth-service:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8000
        env:
        - name: DEBUG
          value: "True"
        - name: DJANGO_SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: fraud-detection-secrets
              key: django-secret-key
        - name: DB_NAME
          value: fraud_detection
        - name: DB_USER
          value: postgres
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: fraud-detection-secrets
              key: postgres-password
        - name: DB_HOST
          value: postgres.fraud-detection.svc.cluster.local
        - name: DB_PORT
          value: "5432"
        - name: REDIS_URL
          value: redis://redis.fraud-detection.svc.cluster.local:6379/1
        livenessProbe:
          httpGet:
            path: /api/users/
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/users/
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 5
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"

---
apiVersion: v1
kind: Service
metadata:
  name: auth-service
  namespace: fraud-detection
spec:
  selector:
    app: auth-service
  type: ClusterIP
  ports:
  - port: 8000
    targetPort: 8000
    name: http
```

---

## Step 5: Push Changes to GitLab

1. Ensure you have K8s manifests in `k8s/` folder
2. Commit and push to `main` or `develop` branch:
   ```bash
   git add k8s/
   git add .gitlab-ci.yml
   git commit -m "Add Kubernetes deployment manifests"
   git push origin main
   ```

3. GitLab CI/CD pipeline will automatically trigger:
   - **test** → runs tests
   - **deploy** → builds images and pushes to GitLab Registry
   - **deploy:k8s** → deploys to your local Kubernetes cluster

---

## Step 6: Monitor Deployment

### In GitLab UI:
1. Go to **Project > CI/CD > Pipelines**
2. Click the pipeline hash
3. Click **deploy:k8s** job to see logs in real-time

### From Command Line:
```bash
# Watch deployment rollout
kubectl rollout status deployment/auth-service -n fraud-detection

# Check pod status
kubectl get pods -n fraud-detection

# View logs
kubectl logs -f deployment/auth-service -n fraud-detection

# Describe pod (if troubleshooting)
kubectl describe pod <pod-name> -n fraud-detection
```

---

## Step 7: Verify Deployment

Once pipeline completes:

```bash
# List all resources in fraud-detection namespace
kubectl get all -n fraud-detection

# Check service endpoints
kubectl get svc -n fraud-detection

# Port-forward to test services locally
kubectl port-forward svc/auth-service 8000:8000 -n fraud-detection
# In another terminal:
curl http://localhost:8000/api/users/
```

---

## Accessing Services

### Option 1: Port-Forward (Quick Testing)
```bash
# Auth service
kubectl port-forward svc/auth-service 8000:8000 -n fraud-detection &

# Transaction service
kubectl port-forward svc/transaction-service 8001:8001 -n fraud-detection &

# Fraud detection service
kubectl port-forward svc/fraud-detection-service 8002:8002 -n fraud-detection &

# Then access:
# http://localhost:8000/api/users/
# http://localhost:8001/health
# http://localhost:8002/health
```

### Option 2: Kubernetes Ingress (Recommended)
Create `k8s/ingress.yaml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fraud-detection-ingress
  namespace: fraud-detection
spec:
  rules:
  - host: localhost
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: auth-service
            port:
              number: 8000
```

Then:
```bash
kubectl apply -f k8s/ingress.yaml
# Access via: http://localhost/api/users/
```

---

## Troubleshooting

### KUBE_CONFIG variable not found
- Go to **Project > Settings > CI/CD > Variables** and verify `KUBE_CONFIG` is added
- Ensure it's not empty

### "Unable to connect to the server"
- Ensure Kubernetes is running: `kubectl cluster-info`
- Verify kubeconfig is valid: `kubectl config view`
- Check base64 encoding: `echo $KUBE_CONFIG | base64 -d | kubectl config view`

### Pods stuck in "Pending" or "ImagePullBackOff"
```bash
kubectl describe pod <pod-name> -n fraud-detection
```
- Check image availability in GitLab Registry
- Verify image pull secrets if using private registry
- Ensure image tag matches what's in manifest

### Services not communicating
- Check service discovery: `kubectl get svc -n fraud-detection`
- Verify DNS: `kubectl exec -it <pod> -n fraud-detection -- nslookup postgres`
- Check network policies: `kubectl get networkpolicy -n fraud-detection`

### Pipeline fails with "kubectl: command not found"
- Ensure runner has `kubectl` installed
- Or use `apk add --no-cache kubectl` before script (already in `.gitlab-ci.yml`)

---

## Automatic Deployment Flow

Every push to `main` or `develop`:

```
git push
    ↓
GitLab detects commit
    ↓
Pipeline starts (test → deploy → deploy:k8s)
    ↓
Tests run (optional skip on success)
    ↓
Images build and push to GitLab Registry
    ↓
✓ deploy:k8s stage:
  - Decodes KUBE_CONFIG
  - Connects to local K8s cluster
  - Creates fraud-detection namespace
  - Applies k8s manifests
  - Updates image tags to latest
  - Waits for rollouts
  - Shows deployment status
    ↓
Services running on local Kubernetes! 🚀
```

---

## Manual Deployment (if needed)

To deploy without pushing code:

1. Go to **Project > CI/CD > Pipelines**
2. Click **Run Pipeline**
3. Select branch (`main` or `develop`)
4. Click **Create pipeline**

Or manually apply manifests:
```bash
kubectl apply -f k8s/ -n fraud-detection
```

---

## Next Steps

1. ✅ Ensure Kubernetes is running locally
2. ✅ Export and add `KUBE_CONFIG` to GitLab CI variables
3. ✅ Create/verify K8s manifests in `k8s/` folder
4. ✅ Push to `main` or `develop`
5. ✅ Monitor pipeline in GitLab UI
6. ✅ Verify services running with `kubectl get pods -n fraud-detection`

**Questions?** Check `kubectl logs` and `kubectl describe` for detailed error info.
