# 🚀 Guide Rapide - CI/CD Kubernetes

## 📊 Pipeline CI/CD Complet

Le pipeline exécute **6 stages** :
1. **LINT** (CI) → Qualité du code
2. **TEST** (CI) → Tests unitaires
3. **INTEGRATION** (CI) → Tests d'intégration
4. **BUILD** (CD) → Construction Docker
5. **DEPLOY** (CD) → Déploiement Kubernetes
6. **SMOKE** (CD) → Validation finale

---

## Déploiement automatique via GitLab

```bash
# 1. Faire vos modifications
git add .
git commit -m "votre message"

# 2. Pousser sur GitLab (déclenche le pipeline)
git push gitlab main

# 3. Suivre le pipeline
# https://gitlab.com/Azaziop/systeme_detect_fraude/-/pipelines
```

---

## Déploiement manuel local

```powershell
# Déploiement complet
.\ci_cd_deploy_k8s.ps1

# Options disponibles
.\ci_cd_deploy_k8s.ps1 -BuildOnly     # Build images uniquement
.\ci_cd_deploy_k8s.ps1 -DeployOnly    # Deploy uniquement
.\ci_cd_deploy_k8s.ps1 -SkipTests     # Sans tests
```

---

## Commandes utiles

```powershell
# Vérifier les pods
kubectl get pods -n fraud-detection

# Vérifier les services
kubectl get svc -n fraud-detection

# Logs d'un service
kubectl logs -l app=transaction-service -n fraud-detection

# Redémarrer un service
kubectl rollout restart deployment/transaction-service -n fraud-detection

# Accéder au frontend
kubectl port-forward svc/frontend-service 3000:80 -n fraud-detection
# http://localhost:3000
```

---

## Structure du Pipeline

```
┌─────────────┐
│  GIT PUSH   │
└─────────────┘
      ↓
┌─────────────┐
│    LINT     │  Qualité du code (flake8, hadolint, security)
└─────────────┘
      ↓
┌─────────────┐
│    TEST     │  Tests unitaires + couverture de code
└─────────────┘
      ↓
┌─────────────┐
│ INTEGRATION │  Tests d'intégration
└─────────────┘
      ↓
┌─────────────┐
│    BUILD    │  Construction des 4 images Docker
└─────────────┘
      ↓
┌─────────────┐
│   DEPLOY    │  Déploiement sur Kubernetes
└─────────────┘
      ↓
┌─────────────┐
│    SMOKE    │  Tests de fumée
└─────────────┘
```

---

## CI vs CD

### **CI (Continuous Integration)** - S'exécute sur TOUS les push
- ✅ Lint : Vérification qualité du code
- ✅ Security : Scan de vulnérabilités  
- ✅ Tests : Tests unitaires avec couverture
- ✅ Integration : Tests d'intégration

### **CD (Continuous Deployment)** - S'exécute UNIQUEMENT sur main
- ✅ Build : Construction des images Docker
- ✅ Deploy : Déploiement Kubernetes
- ✅ Smoke : Validation post-déploiement

---

## Images Docker créées

- `fraud-detection-auth:latest` → Auth Service
- `fraud-detection-transaction:latest` → Transaction Service  
- `fraud-detection-ml:latest` → Fraud Detection Service
- `fraud-detection-frontend:latest` → Frontend

---

## Services déployés

| Service | Port | URL |
|---------|------|-----|
| Auth | 8000 | http://localhost:8000 |
| Transaction | 8001 | http://localhost:8001 |
| Fraud Detection | 8002 | http://localhost:8002 |
| Frontend | 3000 | http://localhost:3000 |
| PostgreSQL | 5432 | (interne) |

---

## Résolution de problèmes

### Le pipeline échoue
1. Vérifier Docker Desktop est lancé
2. Vérifier Kubernetes est activé
3. Vérifier GitLab Runner est actif: `cd C:\GitLab-Runner; .\gitlab-runner.exe status`

### Les pods ne démarrent pas
1. `kubectl get pods -n fraud-detection` → voir l'état
2. `kubectl describe pod <nom-pod> -n fraud-detection` → détails
3. `kubectl logs <nom-pod> -n fraud-detection` → logs

### Redéploiement complet
```powershell
# Supprimer tout
kubectl delete namespace fraud-detection

# Redéployer
.\ci_cd_deploy_k8s.ps1
```

---

Pour plus de détails: voir **CICD_KUBERNETES_DEPLOYMENT.md**
