# Pipeline CI/CD GitLab - Kubernetes Deployment

Ce document décrit le pipeline CI/CD GitLab configuré pour construire et déployer automatiquement le système de détection de fraude sur Kubernetes.

## 📋 Vue d'ensemble

Le pipeline est organisé en **4 stages** :

```
test → build → deploy → smoke
```

### 1️⃣ Stage: TEST
Tests automatiques des différents services (exécuté sur les merge requests).

### 2️⃣ Stage: BUILD
Construction des images Docker pour tous les services.

### 3️⃣ Stage: DEPLOY
Déploiement sur Kubernetes (local ou production).

### 4️⃣ Stage: SMOKE
Tests de fumée pour vérifier que tous les services fonctionnent.

---

## 🚀 Jobs du Pipeline

### **build:docker-images**
- **Stage**: build
- **Déclenchement**: Branche `main` uniquement
- **Description**: Construit les 4 images Docker :
  - `fraud-detection-auth:latest` → Auth Service (Django)
  - `fraud-detection-transaction:latest` → Transaction Service (FastAPI)
  - `fraud-detection-ml:latest` → Fraud Detection Service (FastAPI + ML)
  - `fraud-detection-frontend:latest` → Frontend (React + Nginx)
- **Tags Kubernetes**: Les images sont également taguées avec le préfixe `systeme_detect_fraude-*`

**Sortie attendue**:
```
✓ Auth Service image built
✓ Transaction Service image built
✓ Fraud Detection Service image built
✓ Frontend image built
✓ All images tagged
```

---

### **deploy:kubernetes**
- **Stage**: deploy
- **Déclenchement**: Branche `main` uniquement, après le build
- **Description**: Déploie tous les services sur Kubernetes
- **Namespace**: `fraud-detection`

**Manifestes appliqués dans l'ordre**:
1. `namespace.yaml` - Création du namespace
2. `secrets.yaml` - Secrets (mots de passe PostgreSQL)
3. `configmap.yaml` - Configuration des URLs de services
4. `postgres-deployment.yaml` - Base de données PostgreSQL
5. `auth-service-deployment.yaml` - Service d'authentification
6. `transaction-service-deployment.yaml` - Service de transactions
7. `fraud-detection-service-deployment.yaml` - Service de détection de fraude
8. `frontend-deployment.yaml` - Interface web

**Vérifications**:
- État des pods
- Rollout status de chaque déploiement (timeout: 120s)
- Liste des services disponibles

---

### **smoke:test-services**
- **Stage**: smoke
- **Déclenchement**: Branche `main`, après le déploiement
- **Description**: Vérifie que tous les services répondent correctement

**Tests effectués**:
- ✅ Auth Service (http://localhost:8000)
- ✅ Transaction Service (http://localhost:8001/health)
- ✅ Fraud Detection Service (http://localhost:8002/health)
- ✅ Frontend (http://localhost:3000)

---

## 🛠️ Prérequis

### GitLab Runner Local (Windows)
Le pipeline nécessite un GitLab Runner local avec les tags suivants :
- `windows`
- `local`
- `shell`

**Installation**:
```powershell
# Le runner est déjà configuré dans C:\GitLab-Runner
cd C:\GitLab-Runner
.\gitlab-runner.exe run
```

### Outils requis sur la machine runner
- ✅ Docker Desktop (avec Kubernetes activé)
- ✅ kubectl (configuré pour accéder au cluster)
- ✅ PowerShell 5.1+
- ✅ Python 3.9+

---

## 📦 Variables d'environnement

Définies dans `.gitlab-ci.yml` :
```yaml
AUTH_IMAGE: fraud-detection-auth:latest
TRANSACTION_IMAGE: fraud-detection-transaction:latest
FRAUD_IMAGE: fraud-detection-ml:latest
FRONTEND_IMAGE: fraud-detection-frontend:latest
```

---

## 🔄 Workflow de déploiement

### Déploiement automatique (via GitLab CI/CD)

1. **Push sur la branche `main`**:
   ```bash
   git add .
   git commit -m "Update services"
   git push gitlab main
   ```

2. **Le pipeline s'exécute automatiquement** :
   - Build des images Docker
   - Déploiement sur Kubernetes
   - Tests de fumée

3. **Suivi du pipeline** :
   - Allez sur GitLab : https://gitlab.com/Azaziop/systeme_detect_fraude/-/pipelines
   - Consultez les logs de chaque job

### Déploiement manuel (via script local)

Utilisez le script `ci_cd_deploy_k8s.ps1` :

```powershell
# Déploiement complet (build + deploy + tests)
.\ci_cd_deploy_k8s.ps1

# Build uniquement
.\ci_cd_deploy_k8s.ps1 -BuildOnly

# Deploy uniquement (si images déjà construites)
.\ci_cd_deploy_k8s.ps1 -DeployOnly

# Sans les tests de fumée
.\ci_cd_deploy_k8s.ps1 -SkipTests
```

---

## 🌐 Accès aux services après déploiement

Les services sont déployés dans Kubernetes. Pour y accéder localement :

```powershell
# Port-forward pour tous les services
kubectl port-forward svc/auth-service 8000:8000 -n fraud-detection
kubectl port-forward svc/transaction-service 8001:8001 -n fraud-detection
kubectl port-forward svc/fraud-detection-service 8002:8002 -n fraud-detection
kubectl port-forward svc/frontend-service 3000:80 -n fraud-detection
```

**URLs**:
- 🔐 Auth Service: http://localhost:8000
- 💳 Transaction Service: http://localhost:8001
- 🤖 Fraud Detection Service: http://localhost:8002
- 🌐 Frontend: http://localhost:3000

---

## 🐛 Dépannage

### Le pipeline échoue au stage BUILD
**Problème**: Docker n'est pas disponible ou erreur de construction

**Solutions**:
1. Vérifiez que Docker Desktop est lancé :
   ```powershell
   docker ps
   ```

2. Vérifiez les logs du GitLab Runner :
   ```powershell
   cd C:\GitLab-Runner
   .\gitlab-runner.exe run
   ```

3. Construisez manuellement pour identifier l'erreur :
   ```powershell
   docker build -t fraud-detection-auth:latest -f auth_service/Dockerfile .
   ```

### Le pipeline échoue au stage DEPLOY
**Problème**: Kubernetes n'est pas accessible

**Solutions**:
1. Vérifiez que Kubernetes est activé dans Docker Desktop

2. Testez la connexion :
   ```powershell
   kubectl cluster-info
   kubectl get nodes
   ```

3. Vérifiez le context kubectl :
   ```powershell
   kubectl config current-context
   # Doit afficher: docker-desktop
   ```

### Les tests de fumée échouent
**Problème**: Les services ne répondent pas

**Solutions**:
1. Vérifiez l'état des pods :
   ```powershell
   kubectl get pods -n fraud-detection
   ```

2. Consultez les logs d'un pod :
   ```powershell
   kubectl logs <pod-name> -n fraud-detection
   ```

3. Vérifiez que PostgreSQL est bien démarré :
   ```powershell
   kubectl get pods -n fraud-detection -l app=postgres
   ```

### Le GitLab Runner ne démarre pas
**Problème**: Erreur au démarrage du runner

**Solutions**:
1. Vérifiez le fichier de configuration :
   ```powershell
   cat C:\GitLab-Runner\config.toml
   ```

2. Réenregistrez le runner si nécessaire :
   ```powershell
   cd C:\GitLab-Runner
   .\gitlab-runner.exe register
   ```

3. Redémarrez le runner :
   ```powershell
   .\gitlab-runner.exe restart
   ```

---

## 📊 Monitoring du déploiement

### Vérifier l'état du cluster
```powershell
# Tous les pods dans le namespace
kubectl get pods -n fraud-detection

# État détaillé d'un pod
kubectl describe pod <pod-name> -n fraud-detection

# Logs d'un pod
kubectl logs <pod-name> -n fraud-detection

# Logs en temps réel
kubectl logs -f <pod-name> -n fraud-detection
```

### Vérifier les services
```powershell
# Liste des services
kubectl get svc -n fraud-detection

# Détails d'un service
kubectl describe svc transaction-service -n fraud-detection
```

### Vérifier les déploiements
```powershell
# Liste des déploiements
kubectl get deployments -n fraud-detection

# Historique de rollout
kubectl rollout history deployment/transaction-service -n fraud-detection

# Statut du rollout
kubectl rollout status deployment/transaction-service -n fraud-detection
```

---

## 🔐 Secrets et Configuration

### Secrets Kubernetes
Les secrets sont définis dans `k8s/secrets.yaml` :
- `postgres-password`: Mot de passe PostgreSQL (base64)

**Pour modifier un secret** :
```powershell
# Encoder en base64
$password = "nouveau_mot_de_passe"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($password)
$encodedPassword = [System.Convert]::ToBase64String($bytes)
Write-Host $encodedPassword

# Modifier le fichier secrets.yaml avec la nouvelle valeur
```

### ConfigMap
Les URLs des services sont définies dans `k8s/configmap.yaml` :
- `FRAUD_DETECTION_SERVICE_URL`
- `AUTH_SERVICE_URL`

---

## 📈 Optimisations futures

### À mettre en place :
- [ ] **Registry Docker privé** : Pousser les images vers Docker Hub ou GitLab Container Registry
- [ ] **Ingress Controller** : Remplacer les port-forward par un vrai ingress
- [ ] **Horizontal Pod Autoscaler** : Scaling automatique basé sur la charge
- [ ] **Monitoring** : Prometheus + Grafana
- [ ] **Logging centralisé** : ELK Stack ou Loki
- [ ] **Secrets management** : Utiliser Sealed Secrets ou Vault
- [ ] **Helm Charts** : Packager l'application avec Helm
- [ ] **GitOps** : ArgoCD pour la gestion déclarative

---

## 🎯 Résumé des commandes utiles

```powershell
# Déploiement complet
.\ci_cd_deploy_k8s.ps1

# Vérifier le pipeline GitLab
# https://gitlab.com/Azaziop/systeme_detect_fraude/-/pipelines

# État des pods
kubectl get pods -n fraud-detection

# Accès au frontend
kubectl port-forward svc/frontend-service 3000:80 -n fraud-detection
# Puis ouvrir: http://localhost:3000

# Redémarrer un service
kubectl rollout restart deployment/transaction-service -n fraud-detection

# Supprimer tout le déploiement
kubectl delete namespace fraud-detection
```

---

## 📞 Support

En cas de problème :
1. Consultez les logs du pipeline sur GitLab
2. Vérifiez les logs des pods : `kubectl logs <pod-name> -n fraud-detection`
3. Consultez la documentation Kubernetes : https://kubernetes.io/docs/
4. Vérifiez que tous les prérequis sont installés

---

**Date**: 4 décembre 2025  
**Version du pipeline**: 2.0  
**Cluster Kubernetes**: docker-desktop (local)
